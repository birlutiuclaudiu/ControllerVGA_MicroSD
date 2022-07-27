----------------------------------------------------------------------------------
-- Birlutiu Claudiu-Andrei
-- UTCN CTI-ro
-- GENERATOR DE ADRESE
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;		 --contine tipul std_logic
use IEEE.STD_LOGIC_ARITH.ALL;		 --pentru calcule signal anumite conversii
use IEEE.std_logic_unsigned.all;	 --permite adunari directe pe vectori de biti/std_logic
use work.VgaPackage.all;
 --AM ALES O REZOLUTIE DE 640/480
--aceasta componenta genereza semnalele de timp si sincronizare ale Portului VGA
entity sync_generator is
    Port ( 
           clock_25MHz : in STD_LOGIC;					  --clockul este de 25MHz , pixel rate-ul pentru o rezolutie de 640/480; aceasta inseamna ca 25 M pixels sunt procesati intr-o secunda
           addr_x : out STD_LOGIC_VECTOR (9 downto 0);    --in cadrul monitoareleor CRT aceasta iesire da pozitia relativa pe axa Ox  a fasciculului de electroni sau la modul general- pozitia pe Ox a pixelului curent  
           addr_y : out STD_LOGIC_VECTOR (9 downto 0);	  --in cadrul monitoareleor CRT aceasta iesire da pozitia relativa pe axa Oy  a fasciculului de electroni sau la modul general-pozitia pe Oy a pixelului curent
           hsync : out STD_LOGIC;						  --hsync si vsync reprezinta semnalele care controleaza scanarea monitorului pe orizontala, respectiv verticala
           vsync : out STD_LOGIC;
           enable_image: out STD_LOGIC);			      --acest semnal da informatia despre situatia adresei pixelilor: daca suntem sau nu in zona de display  
end sync_generator;

--obs datele output despre pixeli se dau serial
architecture Behavioral of sync_generator is

--diagramele de timing detaliate se gasesc in documnetatie
--am folosit constante pentru a fi usor modificarea rezolutiei ca metoda de dezvoltare ulterioara a programului

-- numaratoare pentru pozitia pe orizontala,respectiv pe verticala; sunt initializate cu 0
signal h_cntr: std_logic_vector(9 downto 0) := (others =>'0');
signal v_cntr : std_logic_vector(9 downto 0) := (others =>'0');

--semnalul de enable al imaginii care este initializat cu 1
signal enable_image_h: std_logic := '1'; 
signal enable_image_v: std_logic := '1';    

signal enable_v: STD_LOGIC:='0';

begin
    --numaratorurl pentru pozitia orizontala
        horizontal_counter: process (clock_25MHz)				            --procesul depinde doar de clk_25, adica inaintam cu numaratorul in functie doar de acest pixel rate de 25MHz
         begin
           if (rising_edge(clock_25MHz)) then
             if (h_cntr = (H_max - 1)) then			--in momentul in care ajunge la limita din drepta (799) acesta se reseteaza
               h_cntr <= (others =>'0');
             else
               h_cntr <= h_cntr + 1;
             end if;
           end if;
         end process;
		 
		 --semnalul de enable pentru numaratorul pe verticala
		 enable_v <= '1' when h_cntr=H_max - 1 else '0';
         --numaratorul pe verticala;
		-- acesta merge in paralel (concurent) cu processul pentru orizontala
         vertical_counter: process (clock_25MHz)
         begin
           if (rising_edge(clock_25MHz)) then
             if enable_v = '1' then 
                if v_cntr = V_max-1 then 
                    v_cntr <= (others =>'0');
                else 
                    v_cntr <= v_cntr + 1;
                end if;
              end if;
           end if;
         end process; 
		 
		 fsm_horizontal: entity work.fsm_horizontal_sync PORT MAP(
		      clk_25MHz => clock_25MHz,
		      counter_h => h_cntr,
              h_sync =>hsync,
              enable_image_h =>enable_image_h
		 );
		 fsm_vertical: entity work.fsm_vertical_sync PORT MAP(
		      clk_25MHz => clock_25MHz,
		      counter_v => v_cntr,
		      enable_v  => enable_v,
              v_sync => vsync,
              enable_image_v =>enable_image_v
		 );
		 
	   --semnalul intern pentru validare afisare pixe daca se afla in zona de display; in acest caz se compara pozitia unui pixel cu limitele VD si HD 
       enable_image <='1' when enable_image_h='1' and enable_image_v ='1'
							else '0';	                 
	
	 
	 --se asigneaza porturilor de iesire semnalele interne corespunzatoar
	 addr_x  <= h_cntr; 
	 addr_y  <= v_cntr;	
   
end Behavioral;
