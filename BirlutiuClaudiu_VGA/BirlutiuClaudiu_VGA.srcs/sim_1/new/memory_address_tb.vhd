----------------------------------------------------------------------------------
--Birlutiu Claudiu-Andrei
--UTCN CTi-ro
--modul folosit pentru calculul adreselor 
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;
use work.VgaPackage.all;

entity memory_address_tb is
end;

architecture bench of memory_address_tb is

  component memory_address
      port (
      enable : in STD_LOGIC;
      offset_x : in natural range 0 to HD-1;
      offset_y : in natural range 0 to VD-1;
      addr_x : in STD_LOGIC_VECTOR (9 downto 0);
      addr_y : in STD_LOGIC_VECTOR (9 downto 0);
      x_mem_addr : out natural range 0 to 639;
      y_mem_addr : out natural range 0 to 479
    );
  end component;

  -- Clock period
  constant clk_period : time := 5 ns;
  -- Generics

  -- Ports
  signal enable : STD_LOGIC:='0';
  signal offset_x : natural range 0 to HD-1:=0;
  signal offset_y : natural range 0 to VD-1:=0;
  signal addr_x : STD_LOGIC_VECTOR (9 downto 0):=(others =>'0');
  signal addr_y : STD_LOGIC_VECTOR (9 downto 0):=(others =>'0');
  signal x_mem_addr : natural range 0 to 639:=0;
  signal y_mem_addr : natural range 0 to 479:=0;

begin

  memory_address_inst : memory_address
    port map (
      enable => enable,
      offset_x => offset_x,
      offset_y => offset_y,
      addr_x => addr_x,
      addr_y => addr_y,
      x_mem_addr => x_mem_addr,
      y_mem_addr => y_mem_addr
    );
    
    
    gen_inputs: process
    begin
        enable <='1';
        offset_x <= 600; 
        addr_x <= conv_std_logic_vector(638,10);
        wait for 10 ns;
        if x_mem_addr /= (600 + 638) mod 640 then 
            report "EROARE in timpul calcularii adresei pe orizontala" severity error;
        end if;
        
        offset_y <= 24; 
        addr_y <= conv_std_logic_vector(470,10);
        wait for 10 ns;
        if y_mem_addr /= (24 + 470) mod 480 then 
            report "EROARE in timpul calcularii adresei pe verticala" severity error;
        end if;
        
        enable <='0';
        wait for 10 ns;
        if y_mem_addr /=0 or x_mem_addr /=0 then 
            report "Eroare la dezactivarea semnalului de enable; rezultatul ar fi trebuit sa fie 0 pentru ambele adrese";
        end if;
       wait;
    end process; 
end;
