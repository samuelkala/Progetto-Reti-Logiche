-------------------------------------------------------------------

-- Progetto Reti Logiche A.A. 2020/2021

-- Samuel Kala (Codice Persona: 10584699, Matricola: 889701)
-- Mattia Magliano (Codice Persona: 10538658, Matricola: 868570)

-------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity project_reti_logiche is
port (
i_clk : in std_logic;
i_rst : in std_logic;
i_start : in std_logic;
i_data : in std_logic_vector(7 downto 0);
o_address : out std_logic_vector(15 downto 0);
o_done : out std_logic;
o_en : out std_logic;
o_we : out std_logic;
o_data : out std_logic_vector (7 downto 0)
);
end project_reti_logiche;

architecture Behavioral of project_reti_logiche is
    type state_type is (START,FETCH_PIXELS,WRITE_PIXELS,DONE,FIND_MIN_MAX,CONVERT,WAIT_RAM,CONVERT_2,CONVERT_3);
    signal cur_state, next_state : state_type;
    
    signal o_en_next, o_we_next, o_done_next : std_logic := '0';
    signal o_data_next : std_logic_vector(7 downto 0) := "00000000";
    signal o_address_next, o_address_reg : std_logic_vector(15 downto 0) := "0000000000000000";
    signal min, min_next, max, max_next, rows, columns, rows_next, columns_next : std_logic_vector(7 downto 0) := "00000000";
    signal shift_level, shift_level_next : std_logic_vector(7 downto 0) := "00000000";
    signal cur_pixel, cur_pixel_next, new_pixel, new_pixel_next : std_logic_vector(7 downto 0) := "00000000";
    signal delta_value, delta_value_next : std_logic_vector(8 downto 0) := "000000000";
    signal temp_pixel, temp_pixel_next : std_logic_vector(15 downto 0) := "0000000000000000";
    signal min_max_found, min_max_found_next : boolean := false; 
    signal shift_found, shift_found_next : boolean := false;
    
begin
    state_reg: process (i_clk, i_rst)
    begin
        if (i_rst = '1') then
            cur_state <= START;
            o_done <= '0';
            o_en <= '0';
            o_we <= '0';
            min <= "00000000";
            max <= "00000000";
            rows <= "00000000";
            columns <= "00000000";
            delta_value <= "000000000";
            shift_level <= "00000000";
            temp_pixel <= "0000000000000000"; 
            cur_pixel <= "00000000";
            new_pixel<= "00000000";
            min_max_found <= false;
            shift_found <= false;
            
        elsif (i_clk'event and i_clk = '1') then
            cur_state <= next_state;
            o_done <= o_done_next;
            o_en <= o_en_next;
            o_we <= o_we_next;
            o_address <= o_address_next;
            o_address_reg <= o_address_next;
            o_data <= o_data_next;            
            columns <= columns_next;
            rows <= rows_next;
            min <= min_next;
            max <= max_next;  
            delta_value <= delta_value_next;
            shift_level <= shift_level_next;
            temp_pixel <= temp_pixel_next; 
            cur_pixel <= cur_pixel_next;
            new_pixel<= new_pixel_next;
            min_max_found <= min_max_found_next;
            shift_found <= shift_found_next;     
        end if;
    end process;

comb_proc: process (cur_state, i_start, i_data, o_address_reg, min, max, rows,
                             columns, delta_value,shift_level,temp_pixel,cur_pixel,new_pixel, min_max_found, shift_found)
    begin    
        o_done_next <= '0';
        o_en_next <= '0';
        o_we_next <= '0';
        o_data_next <= "00000000";
        o_address_next <= "0000000000000000";
        columns_next <= columns;
        rows_next <= rows;       
        min_next <= min;
        max_next <= max;  
        delta_value_next <= delta_value;
        shift_level_next <= shift_level;
        temp_pixel_next <= temp_pixel; 
        cur_pixel_next <= cur_pixel;
        new_pixel_next <= new_pixel; 
        next_state <= cur_state;
        min_max_found_next <= min_max_found;
        shift_found_next <= shift_found;
        
        case cur_state is
        
        when START =>
            if i_start = '1' then
                next_state <= FETCH_PIXELS;
            end if;
            
        when FETCH_PIXELS =>
            o_en_next <= '1';
            o_we_next <= '0';
            if(min_max_found = false) then
                o_address_next <= std_logic_vector(to_unsigned(0, 16));
            else
                o_address_next <= std_logic_vector(unsigned(o_address_reg) - (unsigned(rows) * unsigned(columns)) + 1);
            end if;
            next_state <= WAIT_RAM;
            
        when WAIT_RAM =>
            o_en_next <= '1';
            o_we_next <= '0';
            o_address_next <= o_address_reg;
            if(min_max_found = false) then
                next_state <= FIND_MIN_MAX;
            else
                if(shift_found = false) then
                    if((unsigned(max) - unsigned(min)) = 255) then
                        delta_value_next <= "100000000";
                    else
                        delta_value_next <= '0' & std_logic_vector(unsigned(max) - unsigned(min) + 1);
                    end if;
                end if;
                next_state <= CONVERT;
            end if;
            
        when FIND_MIN_MAX =>
            o_en_next <= '1';
            o_we_next <= '0';
            if(unsigned(o_address_reg) = 0) then
                columns_next <= i_data;
                o_address_next <= std_logic_vector(unsigned(o_address_reg) + 1);
                next_state <= WAIT_RAM;
            elsif(unsigned(o_address_reg) = 1) then
                rows_next <= i_data;
                o_address_next <= std_logic_vector(unsigned(o_address_reg) + 1);
                next_state <= WAIT_RAM;
            elsif(unsigned(o_address_reg) = 2) then
                min_next <= i_data;
                max_next <= i_data;
                if(unsigned(rows)*unsigned(columns) = 1) then
                    min_max_found_next <= true;
                    o_address_next <= o_address_reg;
                else
                    o_address_next <= std_logic_vector(unsigned(o_address_reg) + 1);
                end if;
                next_state <= WAIT_RAM;
            else
                if(i_data < min) then
                    min_next <= i_data;
                else
                    min_next <= min;
                end if;
                if(i_data > max) then
                    max_next <= i_data;
                else
                    max_next <= max;
                end if;
                if(unsigned(o_address_reg) <= (unsigned(rows) * unsigned(columns)+1)) then
                    if(unsigned(o_address_reg) < (unsigned(rows) * unsigned(columns) +1)) then
                        o_address_next <= std_logic_vector(unsigned(o_address_reg) + 1);
                        next_state <= WAIT_RAM;
                    else
                        min_max_found_next <= true;
                        o_address_next <= std_logic_vector(to_unsigned(2,16));
                        next_state <= WAIT_RAM;    
                    end if;
                end if;
            end if;
            
        when CONVERT =>
            o_en_next <= '1';
            o_we_next <= '0';
            cur_pixel_next <= i_data;
            if(shift_found = false) then
                if(unsigned(delta_value) >= 256) then
                    shift_level_next <= "00000000";
                elsif(unsigned(delta_value) >= 128 and unsigned(delta_value) <= 255) then
                    shift_level_next <= "00000001";
                elsif(unsigned(delta_value) >= 64 and unsigned(delta_value) <= 127) then
                    shift_level_next <= "00000010";
                elsif(unsigned(delta_value) >= 32 and unsigned(delta_value) <= 63) then
                    shift_level_next <= "00000011";
                elsif(unsigned(delta_value) >= 16 and unsigned(delta_value) <= 31) then
                    shift_level_next <= "00000100";
                elsif(unsigned(delta_value) >= 8 and unsigned(delta_value) <= 15) then
                    shift_level_next <= "00000101";    
                elsif(unsigned(delta_value) >= 4 and unsigned(delta_value) <= 7) then
                    shift_level_next <= "00000110";
                elsif(unsigned(delta_value) >= 2 and unsigned(delta_value) <= 3) then
                    shift_level_next <= "00000111";
                else
                    shift_level_next <= "00001000";
                end if;
                shift_found_next <= true;
            end if;
            o_address_next <= o_address_reg;   
            next_state <= CONVERT_2;
        
        when CONVERT_2 =>
            o_en_next <= '1';
            o_we_next <= '0';
            temp_pixel_next <= std_logic_vector(shift_left((unsigned("00000000" & cur_pixel) - unsigned("00000000" & min)), to_integer(unsigned("00000000" & shift_level))));
            o_address_next <= o_address_reg;
            next_state <= CONVERT_3;
            
        when CONVERT_3 =>
            o_en_next <= '1';
            o_we_next <= '0';
            o_address_next <= o_address_reg;
            if (255 > unsigned(temp_pixel)) then
                new_pixel_next <= temp_pixel(7 downto 0);
            else
                new_pixel_next <= "11111111";
            end if;
            next_state <= WRITE_PIXELS;
            
            
        when WRITE_PIXELS =>
            o_en_next <= '1';
            o_we_next <= '1';
            o_data_next <= new_pixel;
            o_address_next <= std_logic_vector(unsigned(o_address_reg) + (unsigned(rows) * unsigned(columns)));
            if(unsigned(o_address_reg) < (unsigned(rows)*unsigned(columns)) + 1) then 
                next_state <= FETCH_PIXELS;
            else
                next_state <= DONE;
            end if;
    
        when DONE =>           
            if (i_start = '0') then  
                min_next <= "00000000";
                max_next <= "00000000";
                rows_next <= "00000000";
                columns_next <= "00000000";
                delta_value_next <= "000000000";
                shift_level_next <= "00000000";
                temp_pixel_next <= "0000000000000000"; 
                cur_pixel_next <= "00000000";
                new_pixel_next <= "00000000";
                o_address_next <= "0000000000000000";   
                min_max_found_next <= false; 
                shift_found_next <= false;       
                next_state <= START;
            else
                o_done_next <= '1';
            end if;
        end case;
    end process;

end Behavioral;