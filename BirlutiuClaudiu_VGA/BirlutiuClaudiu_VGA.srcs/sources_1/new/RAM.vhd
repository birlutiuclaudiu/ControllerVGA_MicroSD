----------------------------------------------------------------------------------
-- Birlutiu Claudiu-Andrei
-- UTCN CTI-ro
-- Modulul ram pentru stocarea cobfiguratiei imaginii de citit
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity RAM is
    Port ( clk : in STD_LOGIC;
           r_addrx : in NATURAL;
           r_addry : in NATURAL;
           w_addrx : in NATURAL;
           w_addry : in NATURAL;
           RW    : in STD_LOGIC; --semnal de enable scriere
           data_in : in STD_LOGIC_VECTOR (3 downto 0);
           data_out : out STD_LOGIC_VECTOR (11 downto 0));
end RAM;

architecture Behavioral of RAM is
   
    
    type TYPE_RAM is array(0 to 119) of STD_LOGIC_VECTOR(160*12-1 downto 0);
    
   
    signal ram_memory : TYPE_RAM:=(others=>(others=>'0'));
begin
   
    ram_process: process(clk)
    begin 
        if rising_edge(clk) then 
            if RW ='1' then
                 ram_memory(w_addry)(4*(w_addrx+1)-1 downto 4*(w_addrx+1)-4) <= data_in;
                 
             end if;
        end if;
    end process;
    data_out <= ram_memory(r_addry)(12*(r_addrx+1)-1 downto 12*(r_addrx+1)-12);    
   
end Behavioral;
