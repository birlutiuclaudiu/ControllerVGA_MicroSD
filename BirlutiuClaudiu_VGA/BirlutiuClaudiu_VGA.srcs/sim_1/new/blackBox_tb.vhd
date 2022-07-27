library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity BlackBox_tb is
end;

architecture bench of BlackBox_tb is

  component BlackBox
      port (
      clk100MHz : in STD_LOGIC;
      resetOperation : in STD_LOGIC;
      resetUC : in STD_LOGIC;
      btnl : in STD_LOGIC;
      btnr : in STD_LOGIC;
      btnc : in STD_LOGIC;
      btnu : in STD_LOGIC;
      btnd : in STD_LOGIC;
      sw_1 : in STD_LOGIC;
      sw_2 : in STD_LOGIC;
      sw : in STD_LOGIC_VECTOR(11 downto 0);
      SD_RESET : out std_logic;
      SD_CD : in std_logic;
      SD_SCK : inout std_logic;
      SD_CMD : inout std_logic;
      SD_DAT : inout std_logic_vector(3 downto 0);
      an : out STD_LOGIC_VECTOR(7 downto 0);
      cat : out STD_LOGIC_VECTOR(7 downto 0);
      tipSD : out STD_LOGIC_VECTOR(1 downto 0);
      error : out STD_LOGIC;
      waitRead : out STD_LOGIC;
      led_0 : out STD_LOGIC;
      led_1 : out STD_LOGIC;
      led_2 : out STD_LOGIC;
      finish : out STD_LOGIC;
      inWork : out STD_LOGIC;
      red : out STD_LOGIC_VECTOR(3 downto 0);
      blue : out STD_LOGIC_VECTOR(3 downto 0);
      green : out STD_LOGIC_VECTOR(3 downto 0);
      hsync : out STD_LOGIC;
      vsync : out STD_LOGIC
    );
  end component;

  -- Clock period
  constant clk_period : time := 10 ns;
  -- Generics

  -- Ports
  signal clk100MHz : STD_LOGIC:='1';
  signal resetOperation : STD_LOGIC:='0';
  signal resetUC : STD_LOGIC:='0';
  signal btnl : STD_LOGIC:='0';
  signal btnr : STD_LOGIC:='0';
  signal btnc : STD_LOGIC:='0';
  signal btnu : STD_LOGIC:='0';
  signal btnd : STD_LOGIC:='0';
  signal sw_1 : STD_LOGIC:='0';
  signal sw_2 : STD_LOGIC:='0';
  signal sw : STD_LOGIC_VECTOR(11 downto 0):=(others=>'0');
  signal SD_RESET : std_logic:='0';
  signal SD_CD : std_logic:='0';
  signal SD_SCK : std_logic:='0';
  signal SD_CMD : std_logic:='0';
  signal SD_DAT : std_logic_vector(3 downto 0):=(others=>'0');
  signal an : STD_LOGIC_VECTOR(7 downto 0):=(others=>'0');
  signal cat : STD_LOGIC_VECTOR(7 downto 0):=(others=>'0');
  signal tipSD : STD_LOGIC_VECTOR(1 downto 0):=(others=>'0');
  signal error : STD_LOGIC:='0';
  signal waitRead : STD_LOGIC:='0';
  signal led_0 : STD_LOGIC:='0';
  signal led_1 : STD_LOGIC:='0';
  signal led_2 : STD_LOGIC:='0';
  signal finish : STD_LOGIC:='0';
  signal inWork : STD_LOGIC:='0';
  signal red : STD_LOGIC_VECTOR(3 downto 0):=(others=>'0');
  signal blue : STD_LOGIC_VECTOR(3 downto 0):=(others=>'0');
  signal green : STD_LOGIC_VECTOR(3 downto 0):=(others=>'0');
  signal hsync : STD_LOGIC:='0';
 
  signal vsync : STD_LOGIC:='0';

begin

  BlackBox_inst : BlackBox
    port map (
      clk100MHz => clk100MHz,
      resetOperation => resetOperation,
      resetUC => resetUC,
      btnl => btnl,
      btnr => btnr,
      btnc => btnc,
      btnu => btnu,
      btnd => btnd,
      sw_1 => sw_1,
      sw_2 => sw_2,
      sw => sw,
      SD_RESET => SD_RESET,
      SD_CD => SD_CD,
      SD_SCK => SD_SCK,
      SD_CMD => SD_CMD,
      SD_DAT => SD_DAT,
      an => an,
      cat => cat,
      tipSD => tipSD,
      error => error,
      waitRead => waitRead,
      led_0 => led_0,
      led_1 => led_1,
      led_2 => led_2,
      finish => finish,
      inWork => inWork,
      red => red,
      blue => blue,
      green => green,
      hsync => hsync,
      vsync => vsync
    );

   clk_process : process
    begin
     clk100MHz <= '1';
     wait for clk_period/2;
     clk100MHz <= '0';
     wait for clk_period/2;
   end process clk_process;
   
   process 
   begin
        resetOperation <= '0'; 
        resetUC <='0';
        SD_DAT <=(others=>'0');
        SD_RESET <= '0';
        
        wait; 
   end process;

end;
