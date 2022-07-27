----------------------------------------------------------------------------------
-- Birlutiu Claudiu-Andrei 
-- UTCN CTI 
-- Unitate de excutie
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity ExecutionUnit is
     PORT(
           clk100MHz : in STD_LOGIC;
           reset :     in STD_LOGIC;
           sw : in STD_LOGIC_VECTOR(11 downto 0);
           move_enable:            in STD_LOGIC;
           change_img_enable  :    in STD_LOGIC;
           effect_enable:          in STD_LOGIC;
           btnl:       in STD_LOGIC;
           btnr:       in STD_LOGIC;
           btnu:       in STD_LOGIC;
           btnd:       in STD_LOGIC;
           --switch-uri
           sw_1:       in STD_LOGIC;
           sw_2:       in STD_LOGIC;
           --semnale card
            SD_RESET:out std_logic;
            SD_CD:   in std_logic;
            SD_SCK:  inout std_logic;
            SD_CMD:  inout std_logic;
            SD_DAT:  inout std_logic_vector(3 downto 0);
           
           --semnale pentru afisor
           an:  out std_logic_vector(7 downto 0);
           cat: out std_logic_vector(7 downto 0);
           
           --semnal ce indica tipul microSD-ului; 00 sau 10 -EROARE , 01-SDHC, 11-Standard
            tipSD:     out STD_LOGIC_VECTOR(1 downto 0); 
            error:     out STD_LOGIC:='0';
            waitRead:  out STD_LOGIC:='0';
           
           
            finish   : out STD_LOGIC:='0'; 
            inWork   : out STD_LOGIC:='0'; 
           
           --semnale culori 
            red   : out STD_LOGIC_VECTOR(3 downto 0);
            blue  : out STD_LOGIC_VECTOR(3 downto 0);
            green : out STD_LOGIC_VECTOR(3 downto 0);
            hsync : out STD_LOGIC; 
            vsync : out STD_LOGIC);
           
end ExecutionUnit;

architecture Behavioral of ExecutionUnit is
     
     signal clk25MHz        : STD_LOGIC:='0';
     signal addr_x          : STD_LOGIC_VECTOR(9 downto 0);
     signal addr_y          : STD_LOGIC_VECTOR(9 downto 0);
    
     signal r_addrx         : NATURAL:=0;
     signal r_addry         : NATURAL:=0;
     signal enable_image    : STD_LOGIC:='0';
     
     signal rgb_filter  :  STD_LOGIC_VECTOR(11 downto 0);
     signal rgb  :    STD_LOGIC_VECTOR(11 downto 0);
     signal h_sync_reg    : STD_LOGIC:='0';
     signal v_sync_reg    : STD_LOGIC:='0';
     
     --semnale iterne pentru offset
     signal offset_x : INTEGER:=0;
     signal offset_y : INTEGER:=0;
     
      --semnal debounce btnl si btnc
    signal btnl_db : STD_LOGIC:='0';
    signal btnr_db : STD_LOGIC:='0';
    signal btnu_db : STD_LOGIC:='0';
    signal btnd_db : STD_LOGIC:='0';
     
begin
    
    MicroSDModul: entity work.ModulMicroSd PORT MAP(
           clk100MHz => clk100MHz,
           clk25MHz  => clk25MHz,
           reset     => reset, 
           enable    => change_img_enable, 
           btnr      => btnr_db, 
           btnl      => btnl_db, 
           --semnale card
            SD_RESET =>SD_RESET,
            SD_CD    =>SD_CD,
            SD_SCK   =>SD_SCK,
            SD_CMD   =>SD_CMD,
            SD_DAT   =>SD_DAT,
           
           --semnale pentru afisor
           an        =>an,
           cat       =>cat,
           
           --semnal ce indica tipul microSD-ului; 00 sau 10 -EROARE , 01-SDHC, 11-Standard
            tipSD    =>tipSD,
            error    =>error,
            waitRead =>waitRead,
           
            finish   =>finish,
            inWork   =>inWork,
            
            addrx => r_addrx, 
            addry => r_addry,
            data_out =>rgb
    );
    
   
    SyncGenerator: entity work.sync_generator PORT MAP(
           clock_25MHz  => clk25MHz,
           addr_x       => addr_x,
           addr_y       => addr_y, 
           hsync        => h_sync_reg,
           vsync        => v_sync_reg, 
           enable_image => enable_image
           );
    
    DivizorFrecventa: entity work.DivizorFrecventa_25 PORT MAP(
           clock_100MHz => clk100MHZ,
           clock_25MHz  => clk25MHz
    );
    
    MemoryAddress: entity work.memory_address PORT MAP (
           enable  => enable_image, 
           offset_x => offset_x,
           offset_y => offset_y,
           addr_x => addr_x,
           addr_y  => addr_y,
           x_mem_addr => r_addrx,
           y_mem_addr => r_addry
           );
       
    ControllerVGA: entity work.controler_VGA PORT MAP( 
         clock_25MHz  => clk25MHz,
           hsync_clock  => h_sync_reg,
           vsync_clock  => v_sync_reg,
           enable_image =>enable_image,
           color   => rgb_filter,
           red     => red, 
           blue    => blue, 
           green   => green, 
           hsync   => hsync, 
           vsync   => vsync
           );
           
    OffsetCounter: entity work.offset_counter port map(        
           clk100MHz    => clk100MHz,
           enable       => move_enable, 
           rst          => reset, 
           left         => btnl_db,
           right        => btnr_db, 
           up           => btnu_db,
           down         => btnd_db,
           offset_x     => offset_x,
           offset_y     => offset_y);
           
           
    EffectGenerator: entity work.Effect_generator port map(
           effect_enable => effect_enable,
           sw => sw,
           grayscale => sw_1,
           sepia     => sw_2,
           rgb       =>rgb, 
           rgb_filter =>rgb_filter
    );
 -------------------------DEBOUNCERE---------------------------------------
    DebouncerLeft: entity work.mpg PORT MAP (
        btn => btnl, 
        clk => clk100MHz, 
        enable => btnl_db
    );
     DebouncerRight: entity work.mpg PORT MAP (
        btn => btnr, 
        clk => clk100MHz, 
        enable => btnr_db
    );
     DebouncerUp: entity work.mpg PORT MAP (
        btn => btnu, 
        clk => clk100MHz, 
        enable => btnu_db
    );
    
    DebouncerDown: entity work.mpg PORT MAP (
        btn => btnd, 
        clk => clk100MHz, 
        enable => btnd_db
    );
  -------------------------------------------------------------------------
end Behavioral;
