library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity RAM_tb is
end;

architecture bench of RAM_tb is

  component RAM
      port (
      clk : in STD_LOGIC;
      r_addrx : in NATURAL;
      r_addry : in NATURAL;
      w_addrx : in NATURAL;
      w_addry : in NATURAL;
      RW : in STD_LOGIC;
      data_in : in STD_LOGIC_VECTOR (3 downto 0);
      data_out : out STD_LOGIC_VECTOR (11 downto 0)
    );
  end component;

  -- Clock period
  constant clk_period : time := 10 ns;
  -- Generics

  -- Ports
  signal clk : STD_LOGIC:='0';
  signal r_addrx : NATURAL:=0;
  signal r_addry : NATURAL:=0;
  signal w_addrx : NATURAL:=0;
  signal w_addry : NATURAL:=0;
  signal RW : STD_LOGIC:='0';
  signal data_in : STD_LOGIC_VECTOR (3 downto 0):=(others=>'0');
  signal data_out : STD_LOGIC_VECTOR (11 downto 0);

begin

  RAM_inst : RAM
    port map (
      clk => clk,
      r_addrx => r_addrx,
      r_addry => r_addry,
      w_addrx => w_addrx,
      w_addry => w_addry,
      RW => RW,
      data_in => data_in,
      data_out => data_out
    );

   clk_process : process
   begin
   clk <= '1';
    wait for clk_period/2;
    clk <= '0';
   wait for clk_period/2;
   end process clk_process;
   
   process
   begin
        wait for 10 ns;
        RW<='1';
        data_in<="1010";
        w_addrx<=1;
        wait for 10 ns;
        RW<='0';
        data_in<="1111";
        wait for 10 ns;
        r_addrx <= 0;
        r_addry <=0;
        wait for 10 ns;
        wait;
        
   end process;

end;
