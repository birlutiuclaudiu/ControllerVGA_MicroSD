----------------------------------------------------------------------------------
-- Name: Birlutiu Claudiu-Andrei
-- UTCN CTI-ro
-- Modul: Unitatea de control
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity ControlUnit is
    Port ( clk100MHz :          in STD_LOGIC;
           btnc :               in STD_LOGIC;
           reset :              in STD_LOGIC;
           move_enable :        out STD_LOGIC;
           effect_enable :      out STD_LOGIC;
           change_img_enable :  out STD_LOGIC;
           led_0 :              out STD_LOGIC;
           led_1 :              out STD_LOGIC;
           led_2 :              out STD_LOGIC
           );
end ControlUnit;

architecture Behavioral of ControlUnit is
    --declararea unui tip enumerat pentru stari
    type STATE_TYPE is (idle, change_image, move_image, effect_image);
    signal state : STATE_TYPE:=idle; 
    
    --semnal de debounce btnc
    signal btnc_db: STD_LOGIC:='0';
begin

    --procesul de trecere in urmatoarea stare
    gen_next_state: process(clk100MHz)
    begin
        if rising_edge(clk100MHz) then 
            if reset='1' then        --reset sincron
                state <=idle;
            else
                case state is 
                    when idle => 
                        state <=change_image;
                    when change_image => 
                        if btnc_db='1' then      --pentru a evita cazul in care butonul sta mai mult activ decat perioada de ceas; ar fi trecut prin mai multe stari
                            state <= move_image;
                        end if;
                    when move_image => 
                        if btnc_db='1' then 
                            state <= effect_image;
                        end if;
                    when effect_image => 
                        if btnc_db='1' then 
                            state <= change_image;
                       end if;
                    when others => state<=idle;
                end case;
            end if;
        end if;
    end process;

    --procesul de determinarea a semnalelor de iesire
    generate_outputs: process(state)
    begin 
        move_enable        <='0';      --ne folosim de proprietatea procesului care va asigna valoarea semnalului doar la ultima expresie de asignare
        effect_enable      <='0';
        change_img_enable  <='0';
        led_0              <='0';
        led_1              <='0';
        led_2              <='0';
        case state is
            when change_image => change_img_enable<='1'; led_0 <='1';
            when move_image   => move_enable<='1';       led_1 <='1';
            when effect_image => effect_enable<='1';     led_2 <='1';
            when others => null ;
        end case;
    end process;
    
    --------------debouncer pentru butonul btc--------------------
    debounce_btn: entity work.mpg PORT MAP (
        btn => btnc, 
        clk => clk100MHz, 
        enable => btnc_db
    );
end Behavioral;
