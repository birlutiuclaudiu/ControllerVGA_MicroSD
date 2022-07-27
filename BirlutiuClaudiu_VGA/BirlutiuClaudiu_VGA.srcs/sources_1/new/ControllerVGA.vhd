

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

--aceasta componenta preia informatiile legate de culoare si sincronizare; elimina problemele eventuale de timing prin procedeul numit pipelineing 
--SE ELIMINA intarzierile rezultate pe caile de date combinationale 
entity controler_vga is
    Port ( clock_25MHz  : in STD_LOGIC;		            --semnalul de clock divizat, pixel rate-ul specific rezolutiei 640/480 @60Hz
           hsync_clock : in STD_LOGIC;      	        --semnalele de sincronizare orizontala signal verticala primite de la geeratorul de adrese 
           vsync_clock : in STD_LOGIC;
           enable_image : in STD_LOGIC;			        --marcheaza zona de display a scanari ecranului
           color : in STD_LOGIC_VECTOR (11 downto 0);	--vectorul de culori primit de memeorie_rom, acesta reprezinta culoarea unui pixel la un anumit timp
           red : out STD_LOGIC_VECTOR (3 downto 0);		--semnalele de la portul VGA
           blue : out STD_LOGIC_VECTOR (3 downto 0);
           green : out STD_LOGIC_VECTOR (3 downto 0);
           hsync : out STD_LOGIC;
           vsync : out STD_LOGIC);
end controler_vga;

architecture Behavioral of controler_vga is
--se iau semnale interne sincronziare scanare ecran
signal h_sync_reg : std_logic := '1';
signal v_sync_reg : std_logic := '1';

--se iau semnale interne pentru vectorii de culori 
signal vga_red_reg   : std_logic_vector(3 downto 0);
signal vga_green_reg : std_logic_vector(3 downto 0);
signal vga_blue_reg  : std_logic_vector(3 downto 0);

--semnalele in urma procesului de pipelining 
signal img_red : std_logic_vector(3 downto 0);
signal img_green: std_logic_vector(3 downto 0);
signal img_blue : std_logic_vector(3 downto 0);	  


begin  
	--se elimina intarzierile
    process (clock_25MHz)
    begin
        if (rising_edge(clock_25MHz)) then		     
            img_red    <= color(11 downto 8);
            img_green  <= color(7 downto 4);
            img_blue   <= color(3 downto 0);
            h_sync_reg  <= hsync_clock;
            v_sync_reg  <= vsync_clock;  
        end if;
    end process;
    
    process (clock_25MHz )							  
    begin
        if (rising_edge(clock_25MHz )) then
            if enable_image = '1' then			     
                 vga_red_reg   <= img_red;	     
                 vga_blue_reg  <= img_blue;
                 vga_green_reg <= img_green;
            else
                vga_red_reg   <= x"0";		    --in cazul in care suntem in afara zonei de display, se pune pe iesiri 0->negru	sau perioada de �blanking�
                vga_blue_reg  <= x"0";
                vga_green_reg <= x"0";
            end if;
        end if;
    end process;
   
	-- se fac asignarile corsepunzatoare
    hsync   <= h_sync_reg;									  
    vsync   <= v_sync_reg;
    red     <= vga_red_reg;
    green   <= vga_green_reg;
    blue    <= vga_blue_reg;
    
end Behavioral;
