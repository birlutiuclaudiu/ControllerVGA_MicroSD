----------------------------------------------------------------------------------
--Birlutiu Claudiu-Andrei
--UTCN CTI-ro
--decodificator pentru afisoare
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

entity ImageCounter is
    generic ( nbImg: NATURAL:=10);
    Port ( clk  :     in STD_LOGIC;
           reset  :   in STD_LOGIC;
           enable :   in STD_LOGIC;
           btnl :     in STD_LOGIC;
           btnr :     in STD_LOGIC;
           imgAddr :  out STD_LOGIC_VECTOR (11 downto 0)
           );
end ImageCounter;


architecture Behavioral of ImageCounter is
      --definire memorie rom cu partea mai putin seminifcativa a adreselor blocurilor 
    --de inceput ale imagininilor
     type TYPE_ROM is array(0 to nbImg-1) of STD_LOGIC_VECTOR(11 downto 0);
     constant IMG_ROM : TYPE_ROM:=(x"00f", 
     x"080", 
     x"0f1",
     x"162",
     x"1d3",
     x"244", 
     x"2b5", 
     x"326", 
     x"397",
     x"408", 
     others=>x"000");
begin
    process(clk)
         variable imgCnt    : INTEGER range 0 to 9:=0;
    begin 
        if rising_edge(clk) then 
            if enable='1' then 
                if reset = '1' then 
                    imgCnt := 0; 
                elsif btnr ='1' then 
                    if imgCnt = nbImg-1 then 
                        imgCnt :=0;
                    else 
                        imgCnt := imgCnt +1;
                    end if;
                elsif btnl = '1' then 
                    if imgCnt = 0 then 
                        imgCnt :=nbImg-1;
                    else 
                        imgCnt := imgCnt -1;
                    end if;
                end if;
            end if;
            imgAddr <= IMG_ROM(imgCnt);
        end if;
    end process;
    

end architecture Behavioral;
