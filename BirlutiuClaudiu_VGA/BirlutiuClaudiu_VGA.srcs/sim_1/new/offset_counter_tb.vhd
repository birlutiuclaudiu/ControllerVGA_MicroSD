----------------------------------------------------------------------------------
-- Birlutiu Claudiu-Andrei
-- Utcn CTI-ro
-- Numaratoarele de offset
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.VgaPackage.all; 
entity offset_counter_tb is
end;

architecture bench of offset_counter_tb is

  component offset_counter
      port (
      clk :     in STD_LOGIC;
      enable :  in STD_LOGIC;
      rst :     in STD_LOGIC;
      left :    in STD_LOGIC;
      right :   in STD_LOGIC;
      up :      in STD_LOGIC;
      down :    in STD_LOGIC;
      offset_x : out natural range 0 to 639;
      offset_y : out natural range 0 to 479
    );
  end component;

  -- Clock period
  constant clk_period : time := 10 ns;
  -- Generics

  -- Ports
  signal clk : STD_LOGIC:='0';
  signal enable : STD_LOGIC:='0';
  signal rst : STD_LOGIC:='0';
  signal left : STD_LOGIC:='0';
  signal right : STD_LOGIC:='0';
  signal up : STD_LOGIC:='0';
  signal down : STD_LOGIC:='0';
  signal offset_x : natural range 0 to 639;
  signal offset_y : natural range 0 to 479;

begin

  offset_counter_inst : offset_counter
    port map (
      clk => clk,
      enable => enable,
      rst => rst,
      left => left,
      right => right,
      up => up,
      down => down,
      offset_x => offset_x,
      offset_y => offset_y
    );

   clk_process : process
        begin
            clk <= '1';
            wait for clk_period/2;
            clk <= '0';
            wait for clk_period/2;
  end process clk_process;
  
  gen_inputs: process
  begin
    if offset_x /=0 or offset_y/=0 then 
        report "EROARE LA INITIALIZARE" severity ERROR;
    end if;
    wait for clk_period;
    -----------------------------------
    up<='1'; 
    enable<='1';
    wait for clk_period;
    if offset_y/=1 then
     report "EROARE LA Incrementare verticala" severity ERROR;
    end if;
    ----------------------------------------
    up<='0';
    down<='1';
    wait for clk_period;
    if offset_y/=0 then
     report "EROARE LA decrementare verticala" severity ERROR;
    end if;
    -------------------------------------------------------
    down<='0';  
    right<='1';
    wait for clk_period;
    if offset_x/= HD-1 then
     report "EROARE LA decrementare orizontala" severity ERROR;
    end if;
    
    ------------------------------------------------------
    right<='0';
    left <='1';
    wait for clk_period;
    if offset_x/= 0 then
     report "EROARE LA incrementare orizontala" severity ERROR;
    end if;
    left<='0';
    enable<='0';
    wait for clk_period;
    left<='1'; up<='1';
    wait for clk_period;
    if offset_x/= 0 and offset_y/= 0 then
     report "EROARE LA semnalul enable" severity ERROR;
    end if;
    left<='0'; up<='0';
    wait;
  end process;

end;
