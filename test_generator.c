//creare un pr che dati in ingresso dei valori di colonna e riga (dim immagine)
//stampi a video i valori in input su 8 bit randomici e ne calcola il risultato convertito


#include<stdio.h>
#include<math.h>
#include<time.h>
#include<stdlib.h>
#define N 16387

int max_fun (int a[], int n);
int min_fun(int a[], int n);
int convert (int mass,int mini,int current,int righe,int colonne);
int minore(int val);
struct new_pixel_node{
	int converted_pixel;
	int pos_RAM;
	struct new_pixel_node* next;
};
typedef struct new_pixel_node* new_pixel;
new_pixel insert_pixels(int row, int columns, int min, int max,int a[]);
int main (){
	
	int rig,col;
	int i;
	int a[N],max, min;
	int num_test;
	new_pixel new_pixel_RAM[50];
	new_pixel list_pixel;
	scanf("%d",&num_test);
	srand(time(NULL));
	
	printf("library ieee;\n"
		"use ieee.std_logic_1164.all;\n"
		"use ieee.numeric_std.all;\n"
		"use ieee.std_logic_unsigned.all;\n");
		
	printf("\n\n");
	
	printf("entity project_tb is\n"
			"end project_tb;\n");
			
	printf("\n\n");
	
	printf("architecture projecttb of project_tb is\n"
"constant c_CLOCK_PERIOD         : time := 15 ns;\n"
"signal   tb_done                : std_logic;\n"
"signal   mem_address            : std_logic_vector (15 downto 0) := (others => '0');\n"
"signal   tb_rst                 : std_logic := '0';\n"
"signal   tb_start               : std_logic := '0';\n"
"signal   tb_clk                 : std_logic := '0';\n"
"signal   mem_o_data,mem_i_data  : std_logic_vector (7 downto 0);\n"
"signal   enable_wire            : std_logic;\n"
"signal   mem_we                 : std_logic;\n");

	printf("\n\n");
	
	printf("type ram_type is array (65535 downto 0) of std_logic_vector(7 downto 0);\n\n");
	printf("signal i: integer := 0;");
		
	printf("\n\n");
	for(int j = 0; j < num_test; j++){
		col = 1+rand()%10;
		rig = 1+rand()%10;
		for (i=0; i<rig*col; i++){
			a[i] = rand()%256;	
		}
		max = max_fun(a, rig*col);
	    min = min_fun(a, rig*col);
		list_pixel = insert_pixels(rig,col,min,max,a);
		new_pixel_RAM[j] = list_pixel; 
		printf("signal RAM%d: ram_type := (",j);
		printf("%d => std_logic_vector(to_unsigned(%d, 8)), \n", 0, col);
		printf("%d => std_logic_vector(to_unsigned(%d, 8)), \n", 1, rig);
		for(i=0; i <rig*col; i++){
			printf("%d => std_logic_vector(to_unsigned(%d, 8)), \n", i+2, a[i]);
		}
		printf("others => (others =>'0'));\n");
	
		printf("\n\n");
	}
	printf("component project_reti_logiche is\n"
	"port (\n"
      "i_clk         : in  std_logic;\n"
      "i_rst         : in  std_logic;\n"
      "i_start       : in  std_logic;\n"
      "i_data        : in  std_logic_vector(7 downto 0);\n"
      "o_address     : out std_logic_vector(15 downto 0);\n"
      "o_done        : out std_logic;\n"
      "o_en          : out std_logic;\n"
      "o_we          : out std_logic;\n"
      "o_data        : out std_logic_vector (7 downto 0)\n"
      ");\n");
   
   printf("end component project_reti_logiche;\n");
      
   printf("\n\n");
   
   printf("begin\n"
"UUT: project_reti_logiche\n"
"port map (\n"
          "i_clk      	=> tb_clk,\n"
          "i_rst      	=> tb_rst,\n"
          "i_start       => tb_start,\n"
          "i_data    	=> mem_o_data,\n"
          "o_address  	=> mem_address,\n"
          "o_done      	=> tb_done,\n"
          "o_en   	=> enable_wire,\n"
          "o_we 		=> mem_we,\n"
          "o_data    	=> mem_i_data\n"
          ");\n");
   
   printf("\n");
   
   printf("p_CLK_GEN : process is\n"
"begin\n"
    "wait for c_CLOCK_PERIOD/2;\n"
    "tb_clk <= not tb_clk;\n"
"end process p_CLK_GEN;\n");

	printf("\n\n");
	
	printf("MEM : process(tb_clk)\n"
"begin\n"
    "if tb_clk'event and tb_clk = '1' then\n"
        "if enable_wire = '1' then\n");
		for(int i = 0; i < num_test; i++){
			if(i == 0){
				printf( "if i = 0 then\n"
            	"if mem_we = '1' then\n"
                "RAM0(conv_integer(mem_address))  <= mem_i_data;\n"
                "mem_o_data                      <= mem_i_data after 1 ns;\n"
            	"else\n"
                "mem_o_data <= RAM0(conv_integer(mem_address)) after 1 ns;\n"
            "end if;\n");
			}
			else{
				 printf("elsif i = %d then\n"
            "if mem_we = '1' then\n"
                "RAM%d(conv_integer(mem_address))  <= mem_i_data;\n"
                "mem_o_data                      <= mem_i_data after 1 ns;\n"
            "else\n"
                "mem_o_data <= RAM%d(conv_integer(mem_address)) after 1 ns;\n"
            "end if;\n",i,i,i);
			}  	
		}
    
        printf("end if;\n"
		"end if;\n"
    	"end if;\n"
		"end process;\n");
   
   printf("\n\n");
   
   printf("test : process is\n"
	"begin\n" 
    "wait for 100 ns;\n"
    "wait for c_CLOCK_PERIOD;\n"
    "tb_rst <= '1';\n"
    "wait for c_CLOCK_PERIOD;\n"
    "wait for 100 ns;\n"
    "tb_rst <= '0';\n"
    "wait for c_CLOCK_PERIOD;\n"
    "wait for 100 ns;\n"
    "tb_start <= '1';\n"
    "wait for c_CLOCK_PERIOD;\n"
    "wait until tb_done = '1';\n"
    "wait for c_CLOCK_PERIOD;\n"
    "tb_start <= '0';\n"
    "wait until tb_done = '0';\n"
    "wait for 100 ns;\n");
	if(num_test != 1){
		printf("i <= i + 1;\n");
	}
	
	printf("\n");

	for(int i = 1; i < num_test-1; i++){
		printf("wait for 100 ns;\n"
    "tb_start <= '1';\n"
    "wait for c_CLOCK_PERIOD;\n"
    "wait until tb_done = '1';\n"
    "wait for c_CLOCK_PERIOD;\n"
    "tb_start <= '0';\n"
    "wait until tb_done = '0';\n"
    "wait for 100 ns;\n"
    "i <= i + 1;\n");
	printf("\n");
	}

    if(num_test != 1){
		printf("wait for 100 ns;\n"
    	"tb_start <= '1';\n"
    	"wait for c_CLOCK_PERIOD;\n"
    	"wait until tb_done = '1';\n"
    	"wait for c_CLOCK_PERIOD;\n"
    	"tb_start <= '0';\n"
    	"wait until tb_done = '0';\n"
    	"wait for 100 ns;\n");
	}
   printf("\n\n");
	
	
	
	for(i = 0; i < num_test ;i++){
		new_pixel cur = new_pixel_RAM[i];
		while(cur != NULL){
			printf("assert RAM%d(%d) = std_logic_vector(to_unsigned(%d,8)) report ",i,cur->pos_RAM, cur->converted_pixel); 
			printf(" \" ");
			printf("TEST FALLITO (WORKING ZONE). Expected  %d  found ",cur->converted_pixel);
			printf(" \" ");
			printf("& integer'image(to_integer(unsigned(RAM%d(%d))))  severity failure; \n",i,cur->pos_RAM);
			cur = cur->next;
		}
		printf("\n\n");
	}
	printf("\n");
	printf("assert false report");
	printf(" \" ");
	printf("Simulation Ended! TEST PASSATO");
	printf(" \" ");
	printf("severity failure;\n");
	printf("\n");
	
	printf("end process test;\n");
	printf("end projecttb;");
	
		
	return 0;
	
}

int max_fun(int a[], int n){
	int i, massimo;
	massimo = a[0];
	
	for(i=0; i<n; i++){
		if(a[i]>massimo){
			massimo = a[i];
		}
	}
	
	return massimo;
}

int min_fun(int a[], int n){
	int i, minimo;
	minimo = a[0];
	
	for(i=0; i<n; i++){
		if(a[i]<minimo){
			minimo = a[i];
		}
	}
	
	return minimo;
}

int convert (int mass,int mini,int a,int righe,int colonne){
	int delta_val, shift, temp_pixel, temp_pixel1;
	delta_val = mass - mini;
	shift = (8-floor(log2(delta_val+1)));
	temp_pixel = a - mini;
	temp_pixel1 = temp_pixel * pow(2,shift);
	temp_pixel1 = minore(temp_pixel1);
	return temp_pixel1;
}

int minore(int val){
	if(val>255){
		val = 255;
	}
	
	return val;
}

new_pixel insert_pixels(int row, int columns, int min, int max,int a[]){
	new_pixel new_pixel_list;
	new_pixel cur;
	for(int i = 0; i < row * columns; i++){
		if(i == 0){
			new_pixel_list = malloc(sizeof(struct new_pixel_node));
			cur = new_pixel_list;
			cur->converted_pixel = convert(max,min,a[i],row,columns);
			cur->pos_RAM = (row * columns) + 2;
			cur->next = NULL;
		}else{
			cur->next = malloc(sizeof(struct new_pixel_node));
			cur->next->converted_pixel = convert(max,min,a[i],row,columns);
			cur->next->pos_RAM = (row * columns) + i + 2; 
			cur->next->next = NULL;
			cur = cur->next;
		}
	}
	return new_pixel_list;
}