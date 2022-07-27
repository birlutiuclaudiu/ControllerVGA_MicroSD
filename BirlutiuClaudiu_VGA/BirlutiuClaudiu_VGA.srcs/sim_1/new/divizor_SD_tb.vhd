library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity DivizorFrecventa_SD_tb is
 
end;

architecture bench of DivizorFrecventa_SD_tb is


  -- Clock period
  constant clk_period : time := 10 ns;
  -- Generics
  constant fout : REAL := 0.4;

  -- Ports
  signal clk100Mhz : STD_LOGIC;
  signal clkDivised : STD_LOGIC;

begin

  DivizorFrecventa_SD_inst : entity work.DivizorFrecventa_SD
    generic map (
      fout => fout
    )
    port map (
      clk100Mhz => clk100Mhz,
      clkDivised => clkDivised
    );

 

 clk_process : process
   begin
        clk100Mhz <= '1';
        wait for clk_period/2;
        clk100Mhz <= '0';
       wait for clk_period/2;
  end process clk_process;

end;
