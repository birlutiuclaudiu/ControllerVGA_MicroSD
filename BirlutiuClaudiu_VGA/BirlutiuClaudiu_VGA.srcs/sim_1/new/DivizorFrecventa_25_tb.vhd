----------------------------------------------------------------------------------
--Name: Birlutiu Claudiu-Andrei 
--UTCN CTI -ro
--Divizor de frecventa 25 MHZ test bench
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity DivizorFrecventa_25_tb is
end;

architecture bench of DivizorFrecventa_25_tb is

  component DivizorFrecventa_25
      port (
      clock_100MHz : in STD_LOGIC;
      clock_25MHz : out STD_LOGIC
    );
  end component;

  -- Clock period
  constant clk_period : time := 10 ns;
  -- Generics

  -- Ports
  signal clock_100MHz : STD_LOGIC;
  signal clock_25MHz : STD_LOGIC;

begin

  DivizorFrecventa_25_inst : DivizorFrecventa_25
    port map (
      clock_100MHz => clock_100MHz,
      clock_25MHz => clock_25MHz
    );

   clk_process : process
   begin
   clock_100MHz <= '1';
   wait for clk_period/2;
   clock_100MHz <= '0';
   wait for clk_period/2;
   end process clk_process;
   

end;
