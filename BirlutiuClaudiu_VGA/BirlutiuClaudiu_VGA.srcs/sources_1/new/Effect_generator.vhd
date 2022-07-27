----------------------------------------------------------------------------------
--Birlutiu Claudiu -Andrei 
-- UTCN CTI-ro
-- Proiect Controller VGA
-- Effect generator
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity Effect_generator is
    Port ( 
           effect_enable : in STD_LOGIC;
           sw: in STD_LOGIC_VECTOR(11 downto 0);
           grayscale : in STD_LOGIC;
           sepia : in STD_LOGIC;
           rgb : in STD_LOGIC_VECTOR (11 downto 0);
           rgb_filter : out STD_LOGIC_VECTOR (11 downto 0));
end Effect_generator;

architecture Behavioral of Effect_generator is
    
begin

    process(effect_enable, grayscale, sepia, sw, rgb)
        variable red:      NATURAL; 
        variable green:    NATURAL; 
        variable blue:     NATURAL;
    begin 
        red   := conv_integer(rgb(3 downto 0)); 
        green := conv_integer(rgb(7 downto 4)); 
        blue  := conv_integer(rgb(11 downto 8)); 
        if effect_enable = '1' then 
            if grayscale = '1' then 
                red :=   red/3;
                green := 2 *green/3;
                blue :=  1 * blue/10;
            elsif sepia = '1' then 
                red :=   red/3 + 3*green/4 + blue/10;
                green := red/3 + 2*green/3 + blue/10;
                blue :=  red/5 + green/2   + blue/10;
            else
                red := red + conv_integer(sw(11 downto 8));  
                green:= green + conv_integer(sw(7 downto 4));
                blue := blue + conv_integer(sw(3 downto 0));  
            end if;
         end if;
         rgb_filter <= conv_std_logic_vector(red,4) & conv_std_logic_vector(green,4) &conv_std_logic_vector(blue,4);
    end process;
    
    
    
end Behavioral;
