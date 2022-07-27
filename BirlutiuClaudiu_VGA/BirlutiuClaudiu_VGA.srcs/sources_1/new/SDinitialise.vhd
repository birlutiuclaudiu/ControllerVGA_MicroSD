----------------------------------------------------------------------------------
-- Birlutiu Claudiu-Andrei
-- UTCN CTI-ro
-- Modul initializare card in modul SPI
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity SDinitialise is
    Port ( clk100MHz : in STD_LOGIC;
           reset :     in STD_LOGIC;
           enable:     in STD_LOGIC;
         
           SCK:     out std_logic;
           CS :     out std_logic;
           MOSI:    out std_logic;
           MISO:    in  std_logic;
          
           tipSD:   out STD_LOGIC_VECTOR(1 downto 0);
           finish:  out STD_LOGIC
           
           );
end SDinitialise;

architecture Behavioral of SDinitialise is
    type INIT_STATE is (
    START,           --stare initiala
    WAIT_STATE,      -- stare in care se asteapta cel putin 74 de impulsuri
    SEND_CMD0,       -- trimitere CMD0
    RESPONSE_CMD0,           --verificare raspuns CMD0
    SEND_CMD8,               --trimitere  comanda CMD8
    RESPONSE_CMD8,           --verificare raspuns CMD8
    SEND_CMD55,
    RESPONSE_CMD55,
    SEND_ACMD41,        --trimitere comanda ACMD41
    RESPONSE_ACMD41,    --verificare raspuns ACMD41
    SEND_CMD58,         --trimitere comanda CMD58
    RESPONSE_CMD58,     --verificare raspuns la comanda CMD58
    SDHC_SD,            --card SDHC
    STD_SD,             --card standard
    SEND_CMD16, 
    RESPONSE_CMD16,
    TRANSFER_CMD,       --stare in care se transmit bitii de comanda
    GET_RESPONSE,       --stare in care se primeste raspunsul de la card
    CONTINUE_RESPONSE,  --continuare primire raspuns
    ILLEGAL, 
    STOP
    ); 
    
    --definirea semenalelor de stare
    signal state: INIT_STATE:=START;         --starea curenta
    signal return_state: INIT_STATE:=START;  --starea ce urmeaza dupa executia unei rutine de transfer sau primire de date
    
    
    constant CMD_LENGTH: INTEGER:=56;
    --DEFINIRE COMENZI DE TRIMIS; inainte se pune un octet xFF pentru siguranta transmiterrii comenzii
    constant CMD0 :   STD_LOGIC_VECTOR(CMD_LENGTH-1 downto 0):=x"FF" & b"01_000000" & x"00000000" & x"95";
    constant CMD8:    STD_LOGIC_VECTOR(CMD_LENGTH-1 downto 0):=x"FF" & b"01_001000" & x"000001aa" & x"87";
    constant CMD55:   STD_LOGIC_VECTOR(CMD_LENGTH-1 downto 0):=x"FF" & b"01_110111" & x"00000000" & x"01";   --nu conteaza CRC-ul aici 
    constant ACMD41:  STD_LOGIC_VECTOR(CMD_LENGTH-1 downto 0):=x"FF" & b"01_101001" & x"40000000" & x"01";   --nu conteaza CRC-ul aici
    constant CMD58:   STD_LOGIC_VECTOR(CMD_LENGTH-1 downto 0):=x"FF" & b"01_111010" & x"00000000" & x"ff";   --nu conteaza CRC-ul aici
    constant CMD16  : STD_LOGIC_VECTOR(CMD_LENGTH-1 downto 0):=x"FF" & b"01_010000" & x"00000200" & x"FF";  --nu conteaza crc-ul; va seta blocul de date citit; 512- bytes
  
    --definire semnal process automat de stare
    signal clk   :   STD_LOGIC:='0';
    signal CS_reg:   STD_LOGIC:= '1';
    
    --semnal ce descrie comanda curenta 
    signal currentCMD: STD_LOGIC_VECTOR(CMD_LENGTH-1 downto 0):=CMD0;
    
    --declarare semnal pentru primirea raspunsului de la card
    constant MAX_LENGTH_RESP: INTEGER:=40;                               --R3 si R7 au 40 de biti, in timp ce R1 este pe un octet
    signal   response       : STD_LOGIC_VECTOR(MAX_LENGTH_RESP-1 downto 0):=(others=>'0'); 
    
    --constant valid responses
    constant IDLE_NO_ERRORS_C0  : STD_LOGIC_VECTOR(7 downto 0) := "00000001";  -- Normal R1 code after CMD0.
    constant FINISH_ACMD41      : STD_LOGIC_VECTOR(7 downto 0) := x"00";       --Terminarea initializarii
    
   --semnale auxiliare pentru cele doua ieisiri
   signal SCK_reg :   STD_LOGIC:='0';
   signal tipSD_reg : STD_LOGIC_VECTOR(1 downto 0):="00";
begin

    init_process: process(clk)
        variable bitsCounter     : INTEGER:=0;      --numar de biti ce trebuie procesati; pentru comanda sau raspuns
        variable wait_time_init  : INTEGER:= 160;   --asteptare 74perioade de ceas la inceput
        variable type_response   : STD_LOGIC:='0';  --tipul raspunsului: pe 8 bitit sau 40
        variable finish_inialise : STD_LOGIC:='1';  --cand se termina initializarea cu succes; folosit in verificarea raspunsului CMD58
        
    begin 
        if enable='1' then                --acest proces se va face doar in cazul in care se primeste enable de la host
           if rising_edge(clk) then
                if reset = '1' then   --resetarea inseamna repornirea procesului de initializare
                    SCK_reg <= '0';
                    state <= START; 
                else 
                    case state is 
                        when START =>    
                            SCK_reg <= '0';
                            currentCMD <= (others => '1');          --se vor trimite biti de 1 pe mosi
                            CS_reg <= '1';                          --se va deselecta cardul microSD
                            wait_time_init := 160;    --se seteaza cate semnale de ceas se vor trimite initial
                            finish_inialise :='0';
                            state <= WAIT_STATE;     
                        
                        when WAIT_STATE => 
                            if wait_time_init = 0 then 
                                state <= SEND_CMD0;     
                            else 
                                wait_time_init :=  wait_time_init - 1;    --se asteapta 80 de clock-uri de frecventa 200 KHz
                                SCK_reg <= not SCK_reg;              --semnalul de ceas transmis cardului va avea jumate din 
                                                                     --frecventa clock-ului procesului
                            end if;
                        
                        when SEND_CMD0 => 
                            CS_reg <= '0';                    --se activeaza chip-selectul pentru transmiterea comenzii
                            bitsCounter := CMD_LENGTH-1;      --se seteaza numarul de biti ce se vor transfera spre micro_SD
                            currentCMD <= CMD0;               --comanda de trasnmis este CMD0
                            type_response := '0';             --tipul de raspuns e pe 8 biti
                            state <= TRANSFER_CMD;            --urmatoarea stare este cea de transmitere cmd spre card
                            return_state <= RESPONSE_CMD0;    --se defineste starea in care se va ajunge in momentul in care
                                                              --se termina transmiterea comenzii si receptia raspunsului       
                        
                        when RESPONSE_CMD0 => 
                            if response(7 downto 0) = IDLE_NO_ERRORS_C0 then 
                                state <= SEND_CMD8;                   --daca s-a returnat un rapsuns afirmativ => se va trece la urmatorul pas din initializare
                            else 
                                state <= SEND_CMD0;                   -- in caz contrar se va reincerca trimitere comenzii 0
                            end if;
                        
                        when SEND_CMD8 => 
                            CS_reg <= '0';   -- se va activa CS_reg-ul
                            bitsCounter := CMD_LENGTH-1;
                            type_response :='1';
                            currentCMD <= CMD8;
                            state <= TRANSFER_CMD;
                            return_state <= RESPONSE_CMD8;
                        
                        when RESPONSE_CMD8  => 
                            if response(34) ='1' then         
                                state <= ILLEGAL; 
                            elsif response(15 downto 8) /= x"01" then      --voltajul nu e suportat (2.7 - 3.6 V)
                                state <= ILLEGAL;
                            else 
                                state <= SEND_CMD58;
                            end if;
                       
                        when SEND_CMD58 => 
                            CS_reg <= '0';   -- se va activa CS_reg-ul
                            bitsCounter := CMD_LENGTH-1;
                            type_response :='1';
                            currentCMD <= CMD58;
                            state <= TRANSFER_CMD;
                            return_state <= RESPONSE_CMD58;
                           
                            
                            
                         when RESPONSE_CMD58 => 
                            if response(34) ='1' then           --daca s-a inregistrat o comanda invalida se va semnaliza
                                state <= ILLEGAL; 
                            elsif finish_inialise ='1' then    --cazul in care se iese din ACMD41 si se verifica tipul cardului
                                if response(30) = '1' then 
                                    state <= SDHC_SD;
                                else 
                                    state <= STD_SD;
                                end if;
                            else 
                                state <= SEND_CMD55;      --in caz contrar se va continua procesul de initializare cu comanda ACMD41 care va fi insostita initial de CMD55
                            end if;
                           
                          
                         when SEND_CMD55 => 
                            CS_reg <= '0';            -- se va activa CS_reg-ul
                            bitsCounter := CMD_LENGTH-1;
                            type_response :='0';      --R1 rapsuns
                            currentCMD <= CMD55;
                            state <= TRANSFER_CMD;
                            return_state <= RESPONSE_CMD55;
                        
                         when RESPONSE_CMD55 =>        --nu ne intereseaza raspunsul si se va trece la acmd41
                            state <= SEND_ACMD41; 
                         
                         when SEND_ACMD41 => 
                            CS_reg <= '0';            -- se va activa CS_reg-ul
                            bitsCounter := CMD_LENGTH-1;
                            type_response :='0';      --R1 rapsuns
                            currentCMD <= ACMD41;
                            state <= TRANSFER_CMD;
                            return_state <= RESPONSE_ACMD41;
                          
                         
                         when RESPONSE_ACMD41 => 
                            if response(7 downto 0) = IDLE_NO_ERRORS_C0 then 
                                state <= SEND_CMD55;
                            elsif response(7 downto 0) = FINISH_ACMD41 then 
                                finish_inialise :='1';
                                state <= SEND_CMD58;
                            else 
                                state <= ILLEGAL;
                            end if;
               
            
                         when TRANSFER_CMD =>        --stare in care se va transmite comanda la cardul microSD        
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
                                if MISO = '0' then 
                                    response <= response(MAX_LENGTH_RESP-2 downto 0) & MISO;
                                    if type_response ='0' then 
                                        bitsCounter := 6;      --raspuns de tip R1
                                    else 
                                        bitsCounter := 38;     --raspuns de tip R3 si R7 
                                    end if;
                                    state <= CONTINUE_RESPONSE; --se va continua citirea raspunsului
                                 end if;
                             end if;
                             SCK_reg <= not SCK_reg;
                        
                        when CONTINUE_RESPONSE => 
                            if SCK_reg ='1' then 
                                response <= response(MAX_LENGTH_RESP-2 downto 0) & MISO;
                                if bitsCounter = 0 then 
                                    --CS_REG <='1';      --se va deselecta cardul
                                    state <= return_state;
                                else 
                                    bitsCounter := bitsCounter - 1;
                                end if;
                            end if;
                            SCK_reg <= not SCK_reg;
                                    
                       when SDHC_SD => 
                            tipSD_reg <= "01";
                            state <= STOP;
                       when STD_SD =>
                            state <= SEND_CMD16;   --in cazul in care e card standard=> se va seta lungimea blocul de citit
                       
                       when SEND_CMD16 => 
                            CS_reg <= '0';                    --se activeaza chip-selectul pentru transmiterea comenzii
                            bitsCounter := CMD_LENGTH-1;      --se seteaza numarul de biti ce se vor transfera spre micro_SD
                            currentCMD <= CMD16;               --comanda de trasnmis este CMD16
                            type_response := '0';             --tipul de raspuns e pe 8 biti
                            state <= TRANSFER_CMD;            --urmatoarea stare este cea de transmitere cmd spre card
                            return_state <= RESPONSE_CMD16;   --se defineste starea in care se va ajunge in momentul in care
                                                              --se termina transmiterea comenzii si receptia raspunsului       
                        
                        when RESPONSE_CMD16 => 
                            if response(2) = '1' then 
                                state <= ILLEGAL;            --daca CMD16 a returnat un raspuns ilegal se va genera o eroare 
                            else 
                                tipSD_reg <= "11";           --cardul va fi de tipul standard 
                                state <= STOP;
                            end if;
                            
                            
                       when ILLEGAL => 
                            tipSD_reg <= "10";
                            state <= STOP;
                       
                       when STOP => null;
                       when others => state <= START;
                    end case;
                    
                  end if;
         end if;
        end if;
  end process init_process;
  
  tipSd <= tipSD_reg;
  finish <= '1' when state = STOP else '0';
  
  --setarea semnalelor de iesire cu cele interne pentru conectorul de card
  SCK <= SCK_reg;
  MOSI <= currentCMD(CMD_LENGTH-1);
  CS <= CS_reg;
  
  --devizor de ceas pentru obtinerea unui semnal cu frecventa de 400KHz- dublul frecventei semnalului SCk
   DivizorFrecventa_SD_inst : entity work.DivizorFrecventa_SD
    generic map (
      fout => 0.4
    )
    port map (
      clk100Mhz => clk100Mhz,
      clkDivised => clk
    );
    

end Behavioral;
