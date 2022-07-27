----------------------------------------------------------------------------------
--Birlutiu Claudiu-Andrei
--UTCN CTI-ro
--decodificator pentru afisoare
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

entity displ7seg is
    Port ( clk  :   in STD_LOGIC;
           rst  :  in STD_LOGIC;
           data :  in STD_LOGIC_VECTOR (31 downto 0);
           an   :  out STD_LOGIC_VECTOR (7 downto 0);
           seg  :  out STD_LOGIC_VECTOR (7 downto 0));
end displ7seg;

architecture Behavioral of displ7seg is
    constant CLK_100HZ : INTEGER:= 2**20; --oentru divizorul de ceas; va permite o 
                                        --reimprospatare de aproximativ 10 ms
    signal digit: STD_LOGIC_VECTOR(3 downto 0):=x"0";
    signal count : INTEGER range 0 to CLK_100HZ-1 :=0;
    signal count_vector : STD_LOGIC_VECTOR(19 downto 0):=(others=>'0');
    signal anods : STD_LOGIC_VECTOR(7 downto 0):= (others=>'1');
begin
    
    with digit SELect
        seg<= "11111001" when x"1",   --1
         "10100100" when x"2",   --2
         "10110000" when x"3",   --3
         "10011001" when x"4",   --4
         "10010010" when x"5",   --5
         "10000010" when x"6",   --6
         "11111000" when x"7",   --7
         "10000000" when x"8",   --8
         "10010000" when x"9",   --9
         "10001000" when x"A",   --A
         "10000011" when x"B",   --b
         "11000110" when x"C",   --C
         "10100001" when x"D",   --d
         "10000110" when x"E",   --E
         "10001110" when x"F",   --F
         "11000000" when others;   --0
    
    clk_div: process(clk)
    begin
        if rising_edge(clk) then 
            if rst='1' then
                count<=0;
            elsif (count =CLK_100HZ-1) then
                count <= 0;
            else 
                count <= count +1;
            end if;
         end if;
    end process clk_div;
    
    count_vector <= CONV_STD_LOGIC_VECTOR(count, 20);
    
    mux_process: process(count_vector(19 downto 17), data)
        begin 
        case count_vector(19 downto 17) is
            when "000" => digit<=data(3 downto 0);   an<="11111110";
            when "001" => digit<=data(7 downto 4);   an<="11111101";  
            when "010" => digit<=data(11 downto 8);  an<="11111011";
            when "011" => digit<=data(15 downto 12); an<="11110111"; 
            when "100" => digit<=data(19 downto 16); an<="11101111"; 
            when "101" => digit<=data(23 downto 20); an<="11011111"; 
            when "110" => digit<=data(27 downto 24); an<="10111111"; 
            when "111" => digit<=data(31 downto 28); an<="01111111"; 
            when others=> digit<=x"ff";              an<="11111111"; 
         end case;
         end process mux_process;
         
end Behavioral;
