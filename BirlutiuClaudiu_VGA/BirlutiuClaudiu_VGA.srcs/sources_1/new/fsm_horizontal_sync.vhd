---------------------------------------------------------------------------------
-- Birlutiu Claudiu -Andrei 
-- Fsm pentru scanarea pe orizontala
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.VgaPackage.all;

entity fsm_horizontal_sync is
    Port ( clk_25MHz :      in STD_LOGIC;
           counter_h :      in STD_LOGIC_VECTOR(9 downto 0);
           h_sync :         out STD_LOGIC;
           enable_image_h : out STD_LOGIC);
end fsm_horizontal_sync;

architecture Behavioral of fsm_horizontal_sync is
     signal state_horizontal :  STATE_H:=S_HD;
     signal h_sync_reg :        STD_LOGIC:= not(H_pol);
     signal enable_image_h_reg: STD_LOGIC:=not(H_POL);
begin
    --procesul pentru starea urmatoare
     gen_horizontal_state: process(clk_25MHz)
     begin
      if rising_edge(clk_25MHz) then  
        case state_horizontal is 
          when S_HD => 
              if counter_h < HD-1 then 
                state_horizontal <= S_HD;
              else
                state_horizontal <= S_HF;
              end if;
          when S_HF => 
              if counter_h < HD+HF-1 then 
                state_horizontal <= S_HF;
              else 
                state_horizontal <= S_HR;
              end if;
          when S_HR => 
              if counter_h < HD+HF+HR-1 then 
                state_horizontal <= S_HR;
              else 
                state_horizontal <= S_HB;
              end if;
          when S_HB => 
              if counter_h < HD+HF+HR+HB-1 then 
                state_horizontal <= S_HB;
              else 
                state_horizontal <= S_HD;
              end if;
          when others=> state_horizontal <= S_HD;
        end case;
      end if;
  end process gen_horizontal_state;

   --procesul pentru generare iesiri
  gen_outputs_h: process(state_horizontal)
  begin   
      case state_horizontal is 
          when S_HR => 
                h_sync_reg <= H_pol;
                enable_image_h <='0';
          when S_HD => 
                enable_image_h <='1';
                h_sync_reg <=not(H_pol); 
          when others => 
                h_sync_reg <=not(H_pol); 
                enable_image_h <='0';
      end case;
  end process gen_outputs_h;
 
  h_sync <= h_sync_reg;
  
end Behavioral;
