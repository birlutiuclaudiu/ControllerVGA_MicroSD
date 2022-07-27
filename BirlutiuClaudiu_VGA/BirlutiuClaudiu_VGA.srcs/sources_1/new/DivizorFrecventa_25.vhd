----------------------------------------------------------------------------------
--Name: Birlutiu Claudiu-Andrei 
--UTCN CTI -ro
--Divizor de frecventa 25 MHZ
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;		  --pentru  a folosi tipul std logic	    
use ieee.std_logic_unsigned.all;      --se foloseste aceasta librarie pentru  a putea face calcule directe pe vectori de biti
use IEEE.NUMERIC_STD.ALL;

entity DivizorFrecventa_25 is
    Port ( clock_100MHz : in STD_LOGIC;		     --semnalul de intrare este semnalul de la oscilatorul de cuart al placii care are o frecventa de 100 Mhz-> perioada de 10 ns
           clock_25MHz : out STD_LOGIC);		 --semnalul de iesire trebuie sa aiba o frecventa de 25 Mhz cee ce inseamna ca perioada lui este de 40 ns ( 1/(0.000001)*4/100))
end DivizorFrecventa_25;
                                                 --deci, perioada semnalului de iesire este de 4 ori mai mare decat a celui de intrare
                                                 --o metoda de realizare este aceea de a face toggle pe semnalul de iesire dupa 2 perioade ale semnalului de intrare
												 --luam un numarator pe 2 biti (00->01->10->11->00...)-> bitul cel mai semnificativ va da valoarea semnalului de iesire
												 --(dupa cum se observa, acesta se schimba din 2 in 2 impulsuri de ceas)
architecture Behavioral of DivizorFrecventa_25 is
signal clk_divider: unsigned (1 downto 0) := (others=>'0');	   --se ia numaratorul pe 2 biti care e de tipul unsigned pe care il initializam cu 0
begin
    process(clock_100Mhz)  							    
	begin												  
		if rising_edge(clock_100Mhz) then		              --cand se ajunge la frontul crescator al ceasului, numaratorul se incrementeaza; aceasta conditiedetermina de fapt 
			clk_divider <= clk_divider + 1; 			      --trecerea unei perioade pentru semnalul de intrare 
	    else clk_divider <= clk_divider;
		end if;
	end process;
	clock_25MHz <= clk_divider(1);		                      --semnalului de iesire ii va fi asignat bitul cel mai semnificativ al numaratorului

end Behavioral;
