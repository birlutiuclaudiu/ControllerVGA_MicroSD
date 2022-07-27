----------------------------------------------------------------------------------
-- Name:Birlutiu Claudiu-Andrei 
-- UTCN CTI-ro
-- Monopulse generator
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity mpg is
    Port (btn:    in STD_LOGIC;
          clk:    in STD_LOGIC;
          enable: out STD_LOGIC);
end mpg;

architecture Behavioral of mpg is
    signal counter: STD_LOGIC_VECTOR(15 downto 0):=x"0000";
    signal en: STD_LOGIC:='0';
    signal Q1: STD_LOGIC:='0';
    signal Q2: STD_LOGIC:='0';
    signal Q3: STD_LOGIC:='0';
begin
   
   --un counter pe 16 biti 
   counter1: process(clk)
             begin
                if rising_edge(clk) then
                   counter<=counter+1; 
                end if;
    end process;
    --enable-ul de la acest counter se primeste la ultima stare a lui
    en<='1' when counter=x"ffff" else '0';
   
   --in primul bistabil se pune valoarea de la buton
    reg1: process(clk)
         begin
           if rising_edge(clk) then
                if en='1' then
                   Q1<=btn;
                end if;
           end if;
     end process;
    
     reg2: process(clk)
     begin
        if rising_edge(clk) then
                 Q2<=Q1;
        end if;
          end process;
          
     reg3: process(clk)
              begin
                 if rising_edge(clk) then
                          Q3<=Q2;
                 end if;
            end process;
      --va genera un singur impuls sincron cu semnalul de ceas, chiar daca se mentine butonul apasat 
      enable<=Q2 AND not Q3;

end Behavioral;
