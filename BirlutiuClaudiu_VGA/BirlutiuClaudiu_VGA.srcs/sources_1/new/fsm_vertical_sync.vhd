----------------------------------------------------------------------------------
-- Birlutiu Claudiu-Andrei
-- UTCN CTI-ro
-- Fsm pentru scanare pe verticala
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.VgaPackage.all;


entity fsm_vertical_sync is
    Port ( clk_25MHz : in STD_LOGIC;
           counter_v : in STD_LOGIC_VECTOR(9 downto 0);
           enable_image_v : out STD_LOGIC;
           enable_v       : in STD_LOGIC;
           v_sync :         out STD_LOGIC);
end fsm_vertical_sync;

architecture Behavioral of fsm_vertical_sync is
    signal state_vertical   : STATE_V:=S_VD;
    signal v_sync_reg : STD_LOGIC:= not(V_POL);
    
begin

--procesul pentru starea urmatoare
gen_next_state_vertical: process(clk_25MHz)
  begin 
      if rising_edge(clk_25MHz) then 
          case state_vertical is 
              when S_VD => 
                  if counter_v = VD-1 and enable_v='1' then 
                      state_vertical <= S_VF;
                  else 
                      state_vertical <= S_VD;
                  end if;
              when S_VF => 
                  if counter_v = VD+VF-1 and enable_v='1' then 
                      state_vertical <= S_VR;
                  else 
                      state_vertical <= S_VF;
                  end if;
              when S_VR =>
                  if counter_v = VD+VF+VR-1 and enable_v='1' then 
                      state_vertical <= S_VB;
                  else 
                      state_vertical <= S_VR;
                  end if;
              when S_VB  => 
                  if counter_v = VD+VF+VR+VB-1 and enable_v='1' then 
                      state_vertical <= S_VD;
                  else
                      state_vertical <= S_VB;
                  end if;
          end case; 
      end if;
  end process gen_next_state_vertical;
  
  --procesul pentru iesiri
  gen_outputs_v: process(state_vertical)
  begin   
      case state_vertical is 
          when S_VR => 
                  v_sync_reg <= V_pol;
                  enable_image_v <='0';
          when S_VD => 
                  enable_image_v <='1';
                  v_sync_reg <=not(V_pol); 
          when others => 
                  v_sync_reg <=not(V_pol); 
                  enable_image_v <='0';
      end case;
  end process gen_outputs_v;

    v_sync <= v_sync_reg;

end Behavioral;
