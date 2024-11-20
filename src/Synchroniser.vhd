--library declaration
library ieee;
use ieee.std_logic_1164.all;

--entity
entity Synchroniser is
	generic(
		IDLE_STATE :std_logic
	);
	port(
		clk:in std_logic;
		Rst:in std_logic;
		Async:in std_logic;
		Synced:out std_logic
	);

end entity;

--architecture
architecture rtl of Synchroniser is
signal synch:std_logic_vector(1 downto 0);

begin
	synch_proc:process(clk,rst)
	begin
		if rst='1' then 
		synch<=(others => IDLE_STATE);
		elsif rising_edge(clk) then
			synch(0)<=Async;
			synch(1)<=synch(0);
		end if;
		
	end process;
	Synced<=synch(1);

end rtl;