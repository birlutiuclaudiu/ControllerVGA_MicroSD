----------------------------------------------------------------------------------
--  Birlutiu Claudiu-Andrei
-- Utcn CTI-ro
-- Numaratoarele de offset
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;		  --pentru folosirea tipului std_logic
use IEEE.STD_LOGIC_ARITH.ALL;		  --pentru opertaii matemtatice
use IEEE.std_logic_unsigned.all;	  --pentru a putea a face operatii de adunare/scadere etc. pe vectori de biti/std_logic
use ieee.math_real.all;
use work.VgaPackage.all;

entity offset_counter is
    Port ( clk100MHz :     in STD_LOGIC;	    
           enable :  in STD_LOGIC;		--este semnalul de la control unit care permite operatia de deplasare a imaginii
           rst :     in STD_LOGIC;	    --vine de la un switch, in cazul in care este activat si suntem in cadrul op de deplasare, acesta reseteaza pozitia imaginii
           left :    in STD_LOGIC;   --semnalele care indica directia de deplasare a imaginii; acestea nu vin direct de la  butoane, ci vor trece prin debouncere pentru stabilizarea lor
           right :   in STD_LOGIC;
           up :      in STD_LOGIC;
           down : in STD_LOGIC;
           offset_x : out natural range 0 to HD-1;     --acest semnal va da cu cat este deplasata imaginea pe orizontala; valoare lui este intre 0 si 639; nu ar  fi avut rost sa fie mai mare intervalul; la 640 ar fi facut un ciclu complet ce e echivalent cu 0 deplasarea
           offset_y : out natural range 0 to VD-1);	  --acest semnal va da cu cat este deplasata imaginea pe orizontala; valoare lui este intre 0 si 479
end offset_counter;

architecture Behavioral of offset_counter is	

--ne luam semnale interne echivalente unor numaratoare modulo 640, respectiv 480; aceste se initializeaza cu 0
signal x_pos: natural range 0 to HD-1 := 0;
signal y_pos: natural range 0 to VD-1 := 0;

begin
    horizontal_counter: process(clk100Mhz) 		  				        --realizarea deplasarii se face sincron cu semnalul de clock
	begin
	   if enable = '1' then	                    --doar cand UC-ul permite aceasta operatie se poate face deplasarea
           if rising_edge(clk100Mhz) then
               if rst = '1'  then		  		--acest semnal este proioritar fata de semnalele de directie
                   x_pos <= 0;							--imaginea revine la pozitia initiala
               else      
                    if left = '1' then 						 
                        if x_pos = 639 then
                             x_pos <= 0;     --daca atinge limita superioara se pleaca din nou de la 0  
                        else 
                            x_pos <= x_pos + 5; 			--se incremeteaza deoarece prin deplasare la stanga se GRABESTE afisarea pixelului, relativ cu pozitia reala a acestuia data de generatorul de adrese
                        end if;
                        
                    elsif right = '1' then 			         
                        if(x_pos = 0) then 
                            x_pos <= 639; 	  --daca se atinge limita inferioara se pleaca de la limita superioara
                        else 
                            x_pos <= x_pos - 5; 			  --in acest caz se face decrementare deoarece se INTARZIE afisarea pixelului cu x_pos 
                        end if;
                    end if;
                end if;        
             end if;
        end if;
    end process;
    
    vertical_counter: process(clk100Mhz)
    begin
    if enable = '1' then	                          --doar cand UC-ul permite aceasta operatie se poate face deplasarea
           if rising_edge(clk100Mhz) then
               if rst = '1'  then		  		      --acest semnal este proioritar fata de semnalele de directie
                   y_pos <= 0;
               elsif down = '1' then 			      --daca se atinge limita inferioara se pleaca de la cea superioara 
                    if y_pos = 0 then 
                        y_pos <= 479; 
                    else
                        y_pos <= y_pos - 5;	      --in acest caz se face decrementare deoarece se INTARZIE afisarea pixelului pe verticala
                    end if;
                    
			   elsif up = '1' then						  
                    if y_pos = 479 then 
                        y_pos <= 0; 	  --daca se atinge limita superioara se pleaca de la 0
                    else 
                        y_pos <= y_pos + 5; 			  --se incrementeza deoarece se GRABESTE afisarea pixelului
                    end if; 
               end if;
           end if;
    end if;
    end process vertical_counter;
    	
	
	--se asigneaza semnalele interne porturilor corespunzatoare
    offset_x <= x_pos;
    offset_y <= y_pos;
    
end Behavioral;
