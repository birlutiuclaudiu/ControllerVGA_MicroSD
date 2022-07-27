----------------------------------------------------------------------------------
-- Name:Birlutiu Claudiu-Andrei 
-- UTCN CTI-ro
-- Monopulse generator
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mpg_tb is
end;

architecture bench of mpg_tb is

  component mpg
      port (
      btn : in STD_LOGIC;
      clk : in STD_LOGIC;
      enable : out STD_LOGIC
    );
  end component;

  -- Clock period
  constant clk_period : time := 5 ns;
  -- Generics

  -- Ports
  signal btn : STD_LOGIC:='0';
  signal clk : STD_LOGIC:='0';
  signal enable : STD_LOGIC:='0';

begin

  mpg_inst : mpg
    port map (
      btn => btn,
      clk => clk,
      enable => enable
    );

   clk_process : process
   begin
        clk <= '1';
        wait for clk_period/2;
        clk <= '0';
        wait for clk_period/2;
   end process clk_process;
    
    gen_test: process
    begin 
        btn <='1';
        wait for 2 ns;
        btn<='0'; 
        wait for 2 ns;
        if enable ='1' then 
            report "ERROR for first test" severity ERROR;
        end if;
        btn <='1';
        wait for 2**16 * 10 ns;
        
        if enable ='1' then 
            report "ERROR"; 
        end if;
        wait;
        end process gen_test;
end;
