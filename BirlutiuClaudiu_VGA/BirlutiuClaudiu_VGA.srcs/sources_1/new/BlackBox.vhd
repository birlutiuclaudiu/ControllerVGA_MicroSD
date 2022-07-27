----------------------------------------------------------------------------------
--Bitlutiu Claudiu-Andrei
--UTCN CTI -ro 
--BlackBox Controller VGA cu preluare imagini de pe card
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity BlackBox is
    port( 
       clk100MHz : in STD_LOGIC; 
       resetOperation :  in STD_LOGIC;  --reset
       resetUC:    in STD_LOGIC;
       btnl:       in STD_LOGIC;
       btnr:       in STD_LOGIC;
       btnc:       in STD_LOGIC;
       btnu:       in STD_LOGIC;
       btnd:       in STD_LOGIC;
       sw_1:       in STD_LOGIC;
       sw_2:       in STD_LOGIC;
       sw : in STD_LOGIC_VECTOR(11 downto 0);
       --semnale card
       SD_RESET:out std_logic;
       SD_CD:   in std_logic;
       SD_SCK:  inout std_logic;
       SD_CMD:  inout std_logic;
       SD_DAT:  inout std_logic_vector(3 downto 0);
       
     
       an :     out STD_LOGIC_VECTOR(7 downto 0);
       cat:     out STD_LOGIC_VECTOR(7 downto 0);
       --semnal ce indica tipul microSD-ului; 00 sau 10 -EROARE , 01-SDHC, 11-Standard
       tipSD:     out STD_LOGIC_VECTOR(1 downto 0); 
       error:     out STD_LOGIC:='0';
       waitRead:  out STD_LOGIC:='0';
       
       --semnale leduri
       led_0    : out STD_LOGIC:='0';  --change image state
       led_1    : out STD_LOGIC:='0';  --move image state
       led_2    : out STD_LOGIC:='0';  --effect image state
       finish   : out STD_LOGIC:='0'; 
       inWork   : out STD_LOGIC:='0'; 
       
       --semnale culori 
       red   : out STD_LOGIC_VECTOR(3 downto 0);
       blue  : out STD_LOGIC_VECTOR(3 downto 0);
       green : out STD_LOGIC_VECTOR(3 downto 0);
       hsync : out STD_LOGIC; 
       vsync : out STD_LOGIC);
end BlackBox;



architecture Behavioral of BlackBox is
    signal move_enable :       STD_LOGIC:='0';
    signal effect_enable :     STD_LOGIC:='0';
    signal change_img_enable : STD_LOGIC:='0';
begin
    
    UC: entity work.ControlUnit port map (
        clk100MHz => clk100MHz,
        btnc => btnc,
        reset => resetUC,    --buton reset
        move_enable => move_enable, 
        effect_enable => effect_enable,
        change_img_enable => change_img_enable, 
        led_0 => led_0,
        led_1 =>led_1, 
        led_2 => led_2    
    );
    
    UE: entity work.ExecutionUnit port map(
       clk100MHz => clk100MHz,
       reset     => resetOperation,
       move_enable         => move_enable,
       effect_enable       => effect_enable,
       change_img_enable   => change_img_enable,
       btnl      => btnl,
       btnr      => btnr, 
       btnu      => btnu,
       btnd      => btnd, 
       sw_1      => sw_1,
       sw_2      => sw_2,
       sw        => sw,
       --semnale card
       SD_RESET => SD_RESET, 
       SD_CD    => SD_CD,
       SD_SCK   => SD_SCK,
       SD_CMD   => SD_CMD,
       SD_DAT   => SD_DAT,
       
       --semnale pentru afisor
       an       => an, 
       cat      =>cat, 
       
       --semnal ce indica tipul microSD-ului; 00 sau 10 -EROARE , 01-SDHC, 11-Standard
      tipSD     => tipSD, 
      error     => error,
      waitRead  => waitRead,
       
     
      finish  => finish, 
      inWork  => inWork,
       --semnale culori 
      red   =>   red, 
      blue  =>   blue, 
      green =>   green, 
      hsync =>   hsync, 
      vsync =>   vsync );

end Behavioral;
