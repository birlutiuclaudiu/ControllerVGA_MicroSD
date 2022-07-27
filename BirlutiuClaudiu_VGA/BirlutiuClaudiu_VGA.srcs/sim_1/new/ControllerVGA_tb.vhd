library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity controler_vga_tb is
end;

architecture bench of controler_vga_tb is

  component controler_vga
      port (
      clock_25MHz : in STD_LOGIC;
      hsync_clock : in STD_LOGIC;
      vsync_clock : in STD_LOGIC;
      enable_image : in STD_LOGIC;
      color : in STD_LOGIC_VECTOR (11 downto 0);
      red : out STD_LOGIC_VECTOR (3 downto 0);
      blue : out STD_LOGIC_VECTOR (3 downto 0);
      green : out STD_LOGIC_VECTOR (3 downto 0);
      hsync : out STD_LOGIC;
      vsync : out STD_LOGIC
    );
  end component;

  -- Clock period
  constant clk_period : time := 5 ns;
  -- Generics

  -- Ports
  signal clock_25MHz : STD_LOGIC:='1';
  signal hsync_clock : STD_LOGIC:='0';
  signal vsync_clock : STD_LOGIC:='0';
  signal enable_image : STD_LOGIC:='0';
  signal color : STD_LOGIC_VECTOR (11 downto 0):=(others=>'0');
  signal red : STD_LOGIC_VECTOR (3 downto 0):=(others=>'0');
  signal blue : STD_LOGIC_VECTOR (3 downto 0):=(others=>'0');
  signal green : STD_LOGIC_VECTOR (3 downto 0):=(others=>'0');
  signal hsync : STD_LOGIC:='0';
  signal vsync : STD_LOGIC:='0';

begin

  controler_vga_inst : controler_vga
    port map (
      clock_25MHz => clock_25MHz,
      hsync_clock => hsync_clock,
      vsync_clock => vsync_clock,
      enable_image => enable_image,
      color => color,
      red => red,
      blue => blue,
      green => green,
      hsync => hsync,
      vsync => vsync
    );

   clk_process : process
   begin
   clock_25MHz <= '1';
   wait for clk_period/2;
     clock_25MHz <= '0';
   wait for clk_period/2;
   end process clk_process;
   
   generare_semnale: process
   begin 
        wait for clk_period;
        enable_image <='1'; 
        color <= x"af4"; 
        hsync_clock<='1'; 
        vsync_clock<='0';
        wait for clk_period; 
        color <= x"af4"; 
        hsync_clock<='1'; 
        vsync_clock<='1';
        wait for clk_period;
        color <= x"af4"; 
        hsync_clock<='0'; 
        vsync_clock<='1';
        wait for clk_period;
        wait;
   end process; 

end;
