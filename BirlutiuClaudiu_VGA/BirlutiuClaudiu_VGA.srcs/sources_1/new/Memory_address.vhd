----------------------------------------------------------------------------------
--Birlutiu Claudiu-Andrei
--UTCN CTi-ro
--modul folosit pentru calculul adreselor 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;		 
use IEEE.STD_LOGIC_ARITH.ALL;		  
use IEEE.std_logic_unsigned.all;	  
use ieee.math_real.all;
use work.VgaPackage.all; 

--ACEASTA COMPONENTA COMBINA INFORMATIILE DE LA NUMARATORUL DE OFFSET SI GENERATORUL DE ADRESE
--aceasta da informatia cand sa se afiseze un pixel
entity memory_address is
    Port ( enable : in STD_LOGIC;							 --enable semnaleaza faptul ca scanarea se afla in regiunea de display
           offset_x : in natural range 0 to HD-1;			 --valoare cu care sa se deplaseze pe orizontala  
           offset_y : in natural range 0 to VD-1;			 --valoarea cu care se deplaseaza pe verticala
           addr_x :     in STD_LOGIC_VECTOR (9 downto 0);		 --pozitia pe orizontala pixelului data de generatorul de adrese (horizontal scan)
           addr_y :     in STD_LOGIC_VECTOR (9 downto 0);		 --pozitia pe verticalca  pixelului data de generatorul de adrese (vertical scan)
           x_mem_addr : out natural range 0 to 159;			 --pozitia pe orizontala cand sa se afiseze pixelul imagini
           y_mem_addr : out natural range 0 to 119);			 --pozitia pe verticala cand sa se afiseze pixelul imagini
           
end memory_address;

architecture Behavioral of memory_address is
--pentru generalitate se folosesc constante 
    constant Height: natural := VD;
    constant Width: natural :=  HD;
begin  

    --se aduna adresa unde ar fi pixelul, data de genertorul de adrese in functie de pixel_rate (deci, cea data in urma scanari ecranului) cu valoarea de deplasare si se face modulo pentru a ramane in intervalul de display    
	--aceasta se realizeaza cand sistemul e in zona de display    	
	--prin operatia de modulo, cand se depaseste limita superioara, rezultatul va incepe de la limita inferioara ; 640%640=0 -> deci, pixelul va fi afisat in partea stanga a ecranului 
	x_mem_addr <= ((conv_integer(addr_x) + offset_x) mod Width)/4 when enable = '1' else 0;
    y_mem_addr <= ((conv_integer(addr_y) + offset_y) mod Height)/4 when enable = '1' else 0;
end Behavioral;
