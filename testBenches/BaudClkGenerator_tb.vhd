--library declaration;
library ieee;
use ieee.std_logic_1164.all;

--entity
entity BaudClkGenerator_tb is
	
end entity;
--architecture
architecture rtl of BaudClkGenerator_tb is

component BaudClkGenerator is
	generic(
		NUMBER_OF_CLOCKS  :integer;
		BAUD_RATE		   :integer;
		SYS_CLK_FREQ  :integer);
	port(
		Clk :in std_logic;
		Rst :in std_logic;
		
		Start :in std_logic;
		BaudClk :out std_logic;
		Ready	  :out std_logic
		);
end component;
	signal clk : std_logic:='0';
	signal Rst : std_logic;
	signal Start : std_logic;
	signal BaudClk : std_logic;
	signal Ready :std_logic;
begin
	clk <= not clk after 18518ps;
	
	UUT :BaudClkGenerator
	generic map(
		NUMBER_OF_CLOCKS  =>10,
		BAUD_RATE		  =>115200,
		SYS_CLK_FREQ  =>27000000)
	port map(
		Clk => Clk,
		Rst => Rst,
		
		Start =>Start,
		BaudClk =>BaudClk,
		Ready	  =>Ready
		);
		
	main:process
	begin
		Rst<='1';
		Start<='0';
		wait for 100ns;
		Rst<='0';
		
		wait until rising_edge(clk);
		Start<='1';
		wait until rising_edge(clk);
		Start<='0';
	
		wait;
	end process;
		

		
		
end rtl;