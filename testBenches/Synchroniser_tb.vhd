--library declaration
library ieee;
use ieee.std_logic_1164.all;

--entity
entity Synchroniser_tb is
	generic(
		IDLE_STATE :std_logic:='1'
	);

end entity;

--architecture
architecture rtl of Synchroniser_tb is
component Synchroniser is
	generic(
		IDLE_STATE :std_logic
	);
	port(
		clk:in std_logic;
		Rst:in std_logic;
		Async:in std_logic;
		Synced:out std_logic
	);

end component;
signal		clk:	std_logic:='0';
signal		Rst:	std_logic;
signal		Async:	std_logic;
signal		Synced: std_logic;
constant 	temp_async:std_logic_vector(7 downto 0):=x"AA";
begin
	clk <= not clk after 18.5ns;
	
	Synchroniser_INST : Synchroniser
	generic map(
		IDLE_STATE =>IDLE_STATE
	)
	port map(
		clk     =>clk,
		Rst		=>Rst,
		Async	=>Async,
		Synced	=>Synced
	);
	
	testBench:process
	begin
	Rst<='1';
	Async<='1';
	wait for 100ns;
	Rst<='0';
	wait for 100ns;
	for i in 0 to 7 loop
	Async<=temp_async(i);
	wait for 100ns;
	end loop;

	
		wait;
	end process;


end rtl;