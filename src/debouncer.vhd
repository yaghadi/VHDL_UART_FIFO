--library declaration
library ieee;
use ieee.std_logic_1164.all;
--entity
entity debouncer is
	port(
	clk         : in std_logic;
    rst         : in std_logic;
    SW_in       : in std_logic;
	SW_OUT      :out std_logic);
end debouncer;
architecture rtl of debouncer is
signal delay_switch :std_logic :='0';
begin
	process(clk,rst)
    begin
        if rst='1' then 
            SW_out<='0';
            delay_switch<='0';
        elsif rising_edge(clk) then
            delay_switch<=SW_in;
            if SW_in ='1' and delay_switch ='0' then
                SW_out <='1';
            else   
                SW_out<='0';
            end if;
        end if;
    end process;
end rtl;