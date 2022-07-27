----------------------------------------------------------------------------------
-- Birlutiu Claudiu-Andrei
-- UTCN CTI-ro
-- modul de de testare sync_generator
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity sync_generator_tb is
--  Port ( );
end sync_generator_tb;

architecture Behavioral of sync_generator_tb is
    signal clock_25MHz :    std_logic:='1';                      --clockul este de 25MHz , pixel rate-ul pentru o rezolutie de 640/480; aceasta inseamna ca 25 M pixels sunt procesati intr-o secunda
    signal addr_x :         std_logic_vector (9 downto 0):=(others=>'0');
    signal addr_y :         std_logic_vector (9 downto 0):=(others=>'0');
    signal hsync :          std_logic:='0';                      --hsync si vsync reprezinta semnalele care controleaza scanarea monitorului pe orizontala, respectiv verticala
    signal vsync :          std_logic:='0'; 
    signal enable_image :   std_logic:='0';   
begin
    
      clock_25MHz<= not(clock_25MHz) after 5 ns;
      DUT: entity work.sync_generator PORT MAP (
         clock_25MHz=>clock_25MHz,
          addr_x => addr_x,
           addr_y => addr_y, 
           hsync =>hsync, 
           vsync => vsync ,
          enable_image=>enable_image
      );
      
      

end Behavioral;
