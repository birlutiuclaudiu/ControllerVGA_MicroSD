----------------------------------------------------------------------------------
-- Birlutiu Claudiu-Andrei
-- UTCN CTI -ro
-- Modul SD controller
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity SDControllerRead is
    Port ( clk100MHz   : in STD_LOGIC;    --semnal de ceas de 100MHz
           reset:        in STD_LOGIC;    
           enable:       in STD_LOGIC;    --se va intra in process numai cand enble-ul e setat => dupa ce s-a realizat procesul de initializare
           address:      in STD_LOGIC_VECTOR(31 downto 0);   --adresa de la care se va incepe citirea datelor
           read_enable : in STD_LOGIC;                       -- validarea citirii de la host
           
           in_work:      out STD_LOGIC;           --semnal ce specifica faptul ca microSD-ul e in lucru
           
           --semnale specifice conectorului microSD
           SCK :         out STD_LOGIC;      --clock transmis cardului
           MOSI :        out STD_LOGIC;   
           MISO :        in STD_LOGIC;
           CS   :        out STD_LOGIC;
           
           ready:           out STD_LOGIC;      --semnal pentru trecerea de starea de start
           finish_read_blk: out STD_LOGIC;      --va semnaliza incheierea citirii unui bloc de date
           dataOut:         out std_logic_vector(512*8-1 downto 0);
           ilegal :         out std_logic:='0');
end SDControllerRead;

architecture Behavioral of SDControllerRead is  
    type SD_STATE is (
    START,              --stare initiala
    WAIT_STATE,         --stare in care se asteapta semnalul de read de la host ca se poate realiza citirea
    SEND_CMD17,         --comanda pentru citirea unui block
    RESPONSE_CMD17,     --primirea raspunsului R1 pentru CMD17                                 
    READ_BLOCK,         --se va incepe citirea blocului 
    GET_BYTE,                   
    TRANSFER_CMD,       --stare in care se transmit bitii de comanda
    GET_RESPONSE,       --stare in care se primeste raspunsul de la card
    CONTINUE_RESPONSE,  --continuare citire raspuns
    ILLEGAL
    ); 
    
 
   --DEFINIRE COMENZI DE TRIMIS
   constant CMD_LENGTH: INTEGER:=56;
   constant CMD17     : STD_LOGIC_VECTOR(CMD_LENGTH-1 downto 0):=x"FF" & b"01_010001" & x"00000000" & x"FF";  --va seta adresa de la care se porneste citirea
    
    --declarare semnale pentru stari
    signal state :       SD_STATE:= START;
    signal return_state: SD_STATE:= START;
    
    --semnal auxiliar pentru chip select
    signal CS_reg: std_logic:='1';      
    
     --semnal ce descrie perioada curenta 
    signal currentCMD: STD_LOGIC_VECTOR(CMD_LENGTH-1 downto 0):=(others =>'1');
    
    --definire semnal de raspuns
    constant MAX_LENGTH_RESP : INTEGER:=8;
    signal response : STD_LOGIC_VECTOR(MAX_LENGTH_RESP- 1 downto 0):=(others=>'0');
    
   
    --definire semnal pe 7 biti primit ca date de la card 
    signal byteVector: STD_LOGIC_VECTOR(7 downto 0):=(others=>'0');
    --semnalul de date auxiliar din blocul de date citit
    signal data_out: STD_LOGIC_VECTOR(512*8-1 downto 0):=(others=>'0');
    
    --definire size-ul blocului de citit
    --data token (1 byte) + Data (512 bytes) + CRC (2 bytes)
    constant BLK_SIZE : INTEGER:= 515;   --atatia bytes se vor citi ca raspuns la comanda CMD17
    
    --definire semnal clk divizat 
    signal clk : STD_LOGIC:='0';
  
    --definire semnal de ceas auxiliar pentru SCK
    signal SCK_reg : std_logic:='0';
    
   
    --semnal intern pentru semnalul de notificare CARD pregatit pentru comenzi citire
    signal ready_reg: STD_LOGIC:='0';
   
begin

    state_proces: process(clk)
        variable bitsCounter     : INTEGER:=0;      --numar de biti ce trebuie procesati; pentru comanda sau raspuns
        variable bytesCounter    : INTEGER:=0;      --numarul de octeti cititi din memoria cardului
        variable returnData      : std_logic:='0';  --daca sa se returneze byte-ul citit de la card hostului sau nu
    begin
        if enable ='1' then 
            if rising_edge(clk) then 
                if reset= '1' then 
                  state <= START; 
                  ready_reg <= '0';        
                else 
                   case state is 
                   
                        when START => 
                            SCK_reg <= '0';
                            finish_read_blk <= '0';
                            CS_reg <='1';           --se va dezactiva chip-selectul pentru moment
                            state <= WAIT_STATE;    --se intra in starea de asteptare a semanlului read_enable de la host
                            ready_reg <= '1';

                        when WAIT_STATE => 
                            if read_enable = '1' then    --daca se primeste acordul de citire => se va trimite comanda
                                state <= SEND_CMD17;   
                                finish_read_blk <='0';
                            end if;
                            
                        when SEND_CMD17  =>                           --comanda ce va cere citirea blocului de memorie de la adresa primita de la host
                            CS_reg <= '0';                            --se va activa chip selectul
                            SCK_reg <= '0';
                            bitsCounter := CMD_LENGTH-1;              --se va seta numarul de de biti ai comenzii
                            currentCMD <= CMD17(CMD_LENGTH-1 downto 40) & address & x"FF";     --formarea comenzii 17 cu adresa primita de la host
                            state <= TRANSFER_CMD;
                            return_state <= RESPONSE_CMD17; 
                            
                            
                        when RESPONSE_CMD17 => 
                            if response(2)='1' then 
                                state <= ILLEGAL; 
                            else 
                                state <= READ_BLOCK;       --daca raspunsul instructiunii de citire a fost ok, se va trece la citirea blocului
                                bytesCounter := BLK_SIZE;
                                
                            end if;
                                
                         when READ_BLOCK => 
                            CS_reg <= '0';
                            returnData := '0';    --in mod implicit nu se doreste transmiterea datelor spre host
                            bitsCounter := 7;     --se primeste un byte de date
                            state <= GET_BYTE; 
                            return_state <= READ_BLOCK;
     
                            if bytesCounter = BLK_SIZE then 
                                bytesCounter := bytesCounter - 1;
                            elsif bytesCounter = BLK_size - 1 then 
                                if byteVector =  x"FF" then  -- cardul nu a raspuns inca
                                    null; 
                                elsif byteVector = x"FE" then --a gasit tokenul de start
                                    returnData := '1' ; --byte-ul urmator va fi de date si se va adauga la datele de iesire
                                    bitsCounter := 512 * 8 -1; --atatia biti se vor citi (512 octeti)
                                    bytesCounter := 2;
                                else 
                                    state <= ILLEGAL; 
                                end if;
                            elsif bytesCounter = 2 then 
                                bytesCounter := bytesCounter - 1;
                            elsif bytesCounter = 1 then 
                                bytesCounter := bytesCounter - 1;
                            else 
                                SCK_reg <='0';
                                CS_reg <='1'; 
                                state <= WAIT_STATE;                  
                                finish_read_blk <='1';  
                            end if;
                                            
                         when GET_BYTE => 
                            if SCK_reg ='1' then 
                                byteVector <= byteVector(6 downto 0) & MISO;
                                if returnData = '1' then 
                                    data_out <= data_out(512*8-2 downto 0) & MISO;
                                end if;
                                if bitsCounter = 0 then  
                                    state <= return_state; 
                                    if returnData = '1' then 
                                        data_out <= data_out(512*8-2 downto 0) & MISO;
                                    end if;  
                                else 
                                    bitsCounter := bitsCounter - 1;
                                end if;
                           end if;
                           sck_reg <= not SCK_reg;
                                        
                                             
                         when TRANSFER_CMD =>                 
                                if SCK_reg = '1' then 
                                    if bitsCounter = 0 then 
                                        state <= GET_RESPONSE;
                                    else
                                        bitscounter := bitscounter -1;
                                        currentCMD <= currentCMD(CMD_LENGTH-2 downto 0) & '1';
                                    end if;
                                 end if;
                                SCK_reg <= not SCK_reg;

        
                        when GET_RESPONSE =>                        --stare in care se va citi raspunsul de la card 
                            if SCK_reg ='1' then 
                                if MISO = '0' then                  --se verifica daca incepe citirea raspunsului
                                    response <= response(MAX_LENGTH_RESP-2 downto 0) & MISO;
                                    bitsCounter := 6;      --raspuns de tip R1
                                    state <= CONTINUE_RESPONSE; --se va continua citirea raspunsului
                                 end if;
                             end if;
                             SCK_reg <= not SCK_reg;
                            
                        when CONTINUE_RESPONSE =>                    --se va continua citirea raspunsului
                            if SCK_reg ='1' then 
                                response <= response(MAX_LENGTH_RESP-2 downto 0) & MISO;
                                if bitsCounter = 0 then 
                                    state <= return_state;
                                else 
                                    bitsCounter := bitsCounter - 1;
                                end if;
                            end if;
                            SCK_reg <= not SCK_reg;
                        
                        when ILLEGAL => ilegal <='1';
                        when others => state<=WAIT_STATE;
                     end case;
                end if;  
            end if;
        end if;      
    end process;
    
  
    --asignarea semnalelor interne
    ready     <= ready_reg;
    dataOut   <= data_out;
    in_work   <= '0' when state = WAIT_STATE or state = ILLEGAL or state = START else '1';
    
    --semnale pentru conectorul microSD
    MOSI <= currentCMD(CMD_LENGTH-1);
    CS   <= CS_reg;
    SCK  <= SCK_reg;
    -------------------------instantiere divizor de ceas de 50 MHZ _dublu fata de SCK-----------------
      DivizorFrecventa_SD_inst : entity work.DivizorFrecventa_SD
    generic map (
      fout => 50.0  --divizor de frecventa 50 MHz= > SCk va fi de 25 MHz
    )
    port map (
      clk100Mhz => clk100Mhz,
      clkDivised => clk
    );
   
end Behavioral;
