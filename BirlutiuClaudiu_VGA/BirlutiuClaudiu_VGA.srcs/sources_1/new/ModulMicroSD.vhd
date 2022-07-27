----------------------------------------------------------------------------------
-- Birlutiu Claudiu-Andrei 
-- UTCN CTI-ro 
-- Modul micro SD
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity ModulMicroSD is
    Port ( clk100MHz : in STD_LOGIC;
           clk25MHz  : in STD_LOGIC;
           reset :     in STD_LOGIC;
           enable :    in STD_LOGIC;
           btnl:       in STD_LOGIC;
           btnr:       in STD_LOGIC;
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
           
           --semnale acces memorie
            addrx :    in NATURAL:=0;
            addry :    in NATURAL:=0;
            data_out : out STD_LOGIC_VECTOR (11 downto 0):=(others=>'0')
           );
end ModulMicroSD;

architecture Behavioral of ModulMicroSD is

           
   --semnal pentru activarea fsm-ului de initializare card
   signal enableSDInit : STD_LOGIC:='0';
   signal CS_init : STD_LOGIC:='1';
   signal MOSI_init : STD_LOGIC:='1';
   signal MISO_init : STD_LOGIC:='1';
   signal SCK_init  : STD_LOGIC:='0';
   signal tipSD_reg:  STD_LOGIC_VECTOR(1 downto 0):="00";
   signal finishInit: STD_LOGIC:='0';
   
    --semnal pentru activarea fsm-ului de citire card
   signal enableSDRead : STD_LOGIC:='0';
   signal CS_read :    STD_LOGIC:='1';
   signal MOSI_read :  STD_LOGIC:='1';
   signal MISO_read :  STD_LOGIC:='1';
   signal SCK_read  :  STD_LOGIC:='0';
   signal readAddress: STD_LOGIC_VECTOR(31 downto 0):=(others=>'0');
   --semnale de notificare
   signal read_enable:   STD_LOGIC:='0';
   signal sd_in_work:    STD_LOGIC:='0';
   signal finish_read_blk : STD_LOGIC:='0';
   signal readySDRead :     STD_LOGIC:='0';
   --declarare semnal pentru octeltul primit de la sd
    signal data_from_sd : STD_LOGIC_VECTOR(512*8 - 1 downto 0):=(others=>'0');
    
    
    --siagnal datatodisplay
    signal dataToDisplay : STD_LOGIC_VECTOR(31 downto 0):= (others=>'0');
    
    
    --definire stari pentu host
    type HOST_STATE is (START, INIT_CARD, START_SD_READ , WAIT_READ, PREPARE_READ, READ_DATA, WRITE_IN_MEMORY, WAIT_WRITE,  ERROR_STATE);
    signal state: HOST_STATE:=START;
    
    --semnal pentru prima imagine 
    signal initial_image : STD_LOGIC:='1';
  
    -----------------------------

    signal w_addrx :  NATURAL:=0;
    signal w_addry :  NATURAL:=0;
    signal RW    :     STD_LOGIC:='0'; --semnal de enable scriere
    signal data_in :   STD_LOGIC_VECTOR (3 downto 0):=(others=>'0');
    signal ilegal : std_logic :='0';
    
    --image adress
    signal imgAddress: STD_LOGIC_VECTOR(11 downto 0):=x"000";
     

begin
   

------------------------------FSM ITINITIALIZARE CARD-----------------------------------------------    
    init_SD_modul: entity work.SDinitialise PORT MAP(
            clk100MHz => clk100MHz, 
            reset     => '0', 
            enable    => enableSDInit,
            SCK       => SCK_init,
            CS        => CS_init, 
            MOSI   => MOSI_init, 
            MISO   => MISO_init, 
            tipSd  => tipSd_reg,
            finish => finishInit
            );
 ------------------------------FSM_CITIRE CARD-------------------------------------------------------         
    read_SD_modul: entity work.SDControllerRead PORT MAP(
           clk100MHz   => clk100MHz, 
           reset       => '0', 
           enable      => enableSDREAD, 
           address     => readAddress, 
          
           read_enable => read_enable,        -- validarea citirii de la host
           in_work     => sd_in_work,         -- semnal ce specifica faptul ca microSD face operatii
           --semnale pentru conectorul sd
           SCK          => SCK_read,
           MOSI         => MOSI_read, 
           MISO         => MISO_read,
           CS           => CS_read,
           
           --semnale ce indica starea autmotuui de citire
           finish_read_blk => finish_read_blk,  
           dataOut         => data_from_sd,
           ilegal          => ilegal,
           ready           => readySDRead
    );
    ---------------------------IMAGE COUNTER------------------------------------------------------------
    Image_counter: entity work.ImageCounter generic map (nbImg => 10)
    port map (clk =>clk100MHz,   
           reset =>reset, 
           enable => enable, 
           btnl =>btnl, 
           btnr => btnr,
           imgAddr=> imgAddress);
    
    -----------------------SEMNALE CONNECTO MICRO SD-----------------------------------------------------------
    SD_SCK <=   SCK_init when enableSDInit ='1' and enableSDRead ='0' else SCK_read  when enableSDRead ='1' else '0'; 
    SD_DAT(3) <= CS_init when enableSDInit ='1' and enableSDRead ='0' else CS_read   when enableSDRead ='1' else '1'; 
    SD_CMD <=  MOSI_init when enableSDInit ='1' and enableSDRead ='0' else MOSI_read when enableSDRead ='1' else '1';
    MISO_init <= SD_DAT(0);
    MISO_read <= SD_DAT(0);   
    SD_RESET <= '0';  
     
  ----------------------------------AUTOMATUL DE STARE AL HOSTULUI---------------------------------------------  
    state_machine_host: process(clk25MHz)
         variable contorByte: INTEGER:=0;   --contor bytes prelucrati 
         variable waiting   : INTEGER:=4;   --contor pentru timpul de asteptare
    begin 
        if enable = '1' then               --doar cand semnalul de enable e pornit se va realiza procesul hostului
            if rising_edge(clk25MHz) then 
                if reset = '1' and state /=ERROR_STATE then 
                    RW <='0';
                    enableSDRead <= '1';
                    enableSDInit <= '0'; --sa nu se mai reseteaze cardul; deja el e resetat
                    initial_image <= '1';
                    state <= START_SD_READ; 
                    
                else 
                    case state is               
                        when START =>  
                            RW <='0';   
                            enableSDInit <= '1';      --se va incepe cu initializarea cardului
                            state <= INIT_CARD;       --se va incepe initializarea cardului
                        
                        when INIT_CARD =>            
                            if finishInit = '1' then 
                                enableSDInit <='0';          --se va dezactiva fsm-ul de initializare
                                if tipSd_reg = "10" then     --daca nu s-a termninat 
                                    state <= ERROR_STATE;
                                elsif tipSd_reg /= "00" then 
                                     enableSDRead  <= '1';
                                     state         <= START_SD_READ;     --dupa terminarea se va seta lungimea blocului
                                end if;
                            end if;
                        
                        when START_SD_READ =>            --se va astepta pana cand se va primi semnalul ready
                            if readySDRead ='1' then 
                                state <= WAIT_READ;     --daca s-a trecut la starea de asteptare in fsm-ul de read
                            end if;
                                
                        
                        when WAIT_READ => 
                            read_enable <= '0';           --in principiu nu se va permite citirrea pana cand se va primi un semnal
                            w_addrx <= 0;                 --adresele de scriere vor incepe de la 0
                            w_addry <= 0;
                            if initial_image = '1' then 
                                state <= PREPARE_READ;       --se va trece la starea de citire date
                                initial_image <= '0';     --nu mai e imaginea initiala
                            elsif btnl = '1' or btnr='1'  then  --apasarea unui buton de schimbare imagine
                                state <=PREPARE_READ;           --se trece la starea de citire date 
                            end if;
                          
                        when PREPARE_READ => 
                            read_enable<='1';    --se activeaza semnalul de citire de pe card
                            readAddress <= x"00000" & imgAddress;  --adresa de la care se va citi;  
                            state <= READ_DATA;
                             
                        when READ_DATA => 
                            if sd_in_work ='1' then 
                                read_enable <='0';
                            end if; 
                            if finish_read_blk = '1' then 
                                state <= WAIT_WRITE; 
                                waiting :=10;
                                contorByte :=511;
                                RW<='1';                --se activeaza citirea 
                                data_in <= data_from_sd(8*(contorByte+1)-1-4 downto 8*contorByte);
                            end if;
                        
                        
                        when WRITE_IN_MEMORY =>
                             state <= WAIT_WRITE;
                             w_addrx <= (w_addrx + 1) mod 480;
                             if w_addrx = 479 and w_addry < 119 then 
                                w_addry <= w_addry + 1;
                                
                             elsif w_addrx = 479 and w_addry = 119 then 
                                RW <= '0';
                                state <= WAIT_READ; 
                             end if;
                            
                             contorByte := contorByte - 1;
                             if contorByte = -1 then
                                RW<='0';
                                read_enable<='1';
                                readAddress <= readAddress + 1;       --adresa urmatorului bloc de citit din SD
                                state <= READ_DATA;  
                              else 
                                data_in <= data_from_sd(8*(contorByte+1)-1-4 downto 8*contorByte); --daca nu, se va lua valoarea de la octet
                             end if; 
                      
                        when WAIT_WRITE =>
                            if waiting = 0 then 
                                waiting :=10;
                                state <= WRITE_IN_MEMORY;
                            else 
                                waiting := waiting- 1;     
                            end if;
                           
                        when ERROR_STATE =>
                             error <='1';
                        when others => 
                            state <= START;         
                    end case; 
                 end if; 
             end if;
         end if;
    end process;
    
--  -----------------------------COUNTER IMAGE ADDRESS-----------------------------------
--    counter_adresa: process(clk100MHz)
--    begin 
--        if rising_edge(clk100MHz) then
--            if state = WAIT_READ then 
--               if btnr_db = '1' then 
--                   readAddress <= readAddress + 1;
--              elsif btnl_db = '1' then 
--                 readAddress <= readAddress - 112;
--              end if;
--            end if;
--        end if;
--    end process;
-- ---------------------------INSTANTIERE MEMORIE VRAM------------------------------------------------------------   
   VRAM_MEMORY:  entity work.RAM 
    port MAP( clk => clk25MHz,
              r_addrx  =>   addrx,
              r_addry  =>   addry,
              w_addrx  =>   w_addrx,
              w_addry  =>   w_addry,
              RW       =>   RW, 
              data_in  =>   data_in, 
              data_out =>   data_out);
    
   
--    dataToDisplay <= data_from_sd(512*8-1 downto 512*8-32);
    
--    Diplay7seg: entity work.displ7seg PORT MAP(
--           clk  => clk100MHz,
--           rst  =>reset,
--           data => dataToDisplay,
--           an   =>an,
--           seg  =>cat
--           );


    ---------------------------------semnale iesire led-uri--------------------------------------------------------
    tipSD <= tipSd_reg;                            --tip card
    finish <= finish_read_blk;                      -- terminare operatie de citit card
    inWork <= sd_in_work;                           --cardul este prin in procesul de initializare sau citire
    waitRead <= '1' when state =WAIT_READ else '0'; --starea de asteptare a unei comenzi
    
  

end Behavioral;
