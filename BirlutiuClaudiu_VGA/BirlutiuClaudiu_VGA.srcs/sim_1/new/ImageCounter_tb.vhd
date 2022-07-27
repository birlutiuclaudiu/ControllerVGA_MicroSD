-------------------------------------
--Birlutiu Claudiu-Andrei 
--UTCN CTI-ro
-------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ImageCounter_tb is
end;

architecture bench of ImageCounter_tb is

  component ImageCounter
    generic (
      nbImg : NATURAL
    );
      port (
      clk : in STD_LOGIC;
      reset : in STD_LOGIC;
      enable : in STD_LOGIC;
      btnl : in STD_LOGIC;
      btnr : in STD_LOGIC;
      imgAddr : out STD_LOGIC_VECTOR (11 downto 0)
    );
  end component;

  -- Clock period
  constant clk_period : time := 10 ns;
  -- Generics
  constant nbImg : NATURAL := 10;

  -- Ports
  signal clk : STD_LOGIC:='1';
  signal reset : STD_LOGIC;
  signal enable : STD_LOGIC;
  signal btnl : STD_LOGIC;
  signal btnr : STD_LOGIC;
  signal imgAddr : STD_LOGIC_VECTOR (11 downto 0);

begin

  ImageCounter_inst : ImageCounter
    generic map (
      nbImg => nbImg
    )
    port map (
      clk => clk,
      reset => reset,
      enable => enable,
      btnl => btnl,
      btnr => btnr,
      imgAddr => imgAddr
    );

      clk_process : process
      begin
      clk <= '1';
      wait for clk_period/2;
      clk <= '0';
      wait for clk_period/2;
      end process clk_process;
      
      generare_semnale: process
      begin 
        reset<='0';
        enable<='1';
        wait for clk_period;
        btnl <='1'; 
        wait for clk_period;
        btnl<='0';
        btnr<='1';
        wait for clk_period;
        btnr<='0';
        wait;
         
      end process;
      

end;
