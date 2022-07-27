----------------------------------------------------------------------------------
-- Name: Birlutiu Claudiu-Andrei
-- UTCN CTI-ro
-- Modul: Unitatea de control test bench
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ControlUnit_tb is
end;

architecture bench of ControlUnit_tb is

  component ControlUnit
      port (
      clk_100MHz : in STD_LOGIC;
      btnc : in STD_LOGIC;
      switch_4 : in STD_LOGIC;
      move_enable : out STD_LOGIC;
      effect_enable : out STD_LOGIC;
      change_img_enable : out STD_LOGIC;
      led_0 : out STD_LOGIC;
      led_1 : out STD_LOGIC;
      led_2 : out STD_LOGIC
    );
  end component;

  -- Clock period
  constant clk_period : time := 10 ns;
  -- Generics

  -- Ports
  signal clk_100MHz : STD_LOGIC;
  signal btnc : STD_LOGIC:='0';
  signal switch_4 : STD_LOGIC;
  signal move_enable : STD_LOGIC;
  signal effect_enable : STD_LOGIC;
  signal change_img_enable : STD_LOGIC;
  signal led_0 : STD_LOGIC;
  signal led_1 : STD_LOGIC;
  signal led_2 : STD_LOGIC;

begin

      DUT : ControlUnit
      port map (
      clk_100MHz => clk_100MHz,
      btnc => btnc,
      switch_4 => switch_4,
      move_enable => move_enable,
      effect_enable => effect_enable,
      change_img_enable => change_img_enable,
      led_0 => led_0,
      led_1 => led_1,
      led_2 => led_2
    );
  
   clk_process : process
   begin
         clk_100MHz <= '1';
         wait for clk_period/2;
         clk_100MHz <= '0';
         wait for clk_period/2;
    end process clk_process;
  
  --vom genera semanle pentru btnc; acestea vor oscila intre 0 si 1 dupa o perioada de ceas
  gen_signal : process
  begin 
    switch_4 <='1'; 
    wait for clk_period;
      if led_0 /='0' or led_1 /='0' or led_2 /='0' or move_enable /= '0' or change_img_enable /='0' or effect_enable /= '0' then 
        report "FAIL for idle" severity ERROR;
    end if;
    wait for clk_period;
    switch_4 <='0'; 
    wait for clk_period;
    -------------------------state change_image
    if led_0 /='1' or led_1 /='0' or led_2 /='0' or move_enable /= '0' or change_img_enable /='1' or effect_enable /= '0' then 
        report "FAIL for change_image" severity ERROR;
    end if;
    wait for clk_period;
    -------------------------------state move_image------------------------
    btnc <='1';
    wait for clk_period;
    if led_0 /='0' or led_1 /='1' or led_2 /='0' or move_enable /= '1' or change_img_enable /='0' or effect_enable /= '0' then 
        report "FAIL for move_image" severity ERROR;
    end if;
    
    btnc <='0';  
    wait for clk_period;
    --------------------------------state effect_image
    btnc <='1';  
    wait for clk_period;
    if led_0 /='0' or led_1 /='0' or led_2 /='1' or move_enable /= '0' or change_img_enable /='0' or effect_enable /= '1' then 
      report "FAIL for effect_image" severity ERROR;
      end if;
      
    btnc <='0'; 
    wait for clk_period;
    -------------------------------tansition effect_image -> state change_image
    btnc <='1'; 
    wait for clk_period;
    if led_0 /='1' or led_1 /='0' or led_2 /='0' or move_enable /= '0' or change_img_enable /='1' or effect_enable /= '0' then 
        report "FAIL for for tansition effect_image -> state change_image" severity ERROR;
    end if;
    btnc <='0';
     wait;
  end process;
end;
