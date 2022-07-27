----------------------------------------------------------------------------------
-- Birlutiu Claudiu-Andrei
-- UTCN CTI-ro
-- Divizor de frecventa general
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.all;

entity DivizorFrecventa_SD is
    generic ( fout: REAL:=0.4);
    Port ( clk100Mhz : in STD_LOGIC;
           clkDivised : out STD_LOGIC);
end DivizorFrecventa_SD;

architecture Behavioral of DivizorFrecventa_SD is
    signal scale: NATURAL:=integer( 100.0 / fout);
    signal counter: NATURAL:=0;
    signal clk_reg : STD_LOGIC:='0';
begin
    
    div: process(clk100MHz)
    begin 
        if rising_edge(clk100MHz) then 
            if counter = scale/2 -1 then 
                clk_reg <= not clk_reg;
                counter <=0;
            else 
                counter <= counter+1;
            end if;
        end if;  
    end process; 
    
    clkDivised <= clk_reg;    

end Behavioral;
