----------------------------------------------------------------------------------
-- Birlutiu Claudiu-Andrei
-- UTCN CTI-ro
-- Modul testare effect generator
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Effect_generator_tb is
end;

architecture bench of Effect_generator_tb is

  component Effect_generator
      port (
      effect_enable : in STD_LOGIC;
      sw : in STD_LOGIC_VECTOR(11 downto 0);
      grayscale : in STD_LOGIC;
      sepia : in STD_LOGIC;
      rgb : in STD_LOGIC_VECTOR (11 downto 0);
      rgb_filter : out STD_LOGIC_VECTOR (11 downto 0)
    );
  end component;


  -- Ports
  signal effect_enable : STD_LOGIC:='0';
  signal sw : STD_LOGIC_VECTOR(11 downto 0):=(others=>'0');
  signal grayscale : STD_LOGIC:='0';
  signal sepia : STD_LOGIC:='0';
  signal rgb : STD_LOGIC_VECTOR (11 downto 0):=(others=>'0');
  signal rgb_filter : STD_LOGIC_VECTOR (11 downto 0):=(others=>'0');

begin

  Effect_generator_inst : Effect_generator
    port map (
      effect_enable => effect_enable,
      sw => sw,
      grayscale => grayscale,
      sepia => sepia,
      rgb => rgb,
      rgb_filter => rgb_filter
    );

    process
    begin 
        rgb<=x"acd";
        wait for 10 ns; 
        effect_enable<='1';
        sepia <='1';     --aplicare efect sepia
        wait for 10 ns; 
        sepia<='0';
        grayscale<='1';   --aplicare efect grayscale
        wait for 10 ns; 
        grayscale<='0';     --aplicare efect de pe switch-uri
        sw <= x"123";
        wait for 10 ns;
        effect_enable <='0';  
        wait;
        
    end process;
end;
