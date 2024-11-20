--library decalration
library ieee;
use ieee.std_logic_1164.all;
--entity 
entity Serialiser_tb is

end entity;

architecture rtl of Serialiser_tb is


	component Serialiser is
	generic(
		Dwidth :integer :=8
	);
	port(
		clk : in std_logic;
		rst : in std_logic;
		
		Load :in std_logic;
		ShiftEn :in std_logic;
		Din 	:in std_logic_vector(Dwidth-1 downto 0);
		Dout	:out std_logic
	);
		
	end component;
	
constant Dwidth :integer :=8;
signal	clk :  std_logic:='0';
signal	rst :  std_logic;
		
signal	Load : std_logic;
signal	ShiftEn : std_logic;
signal	Din 	: std_logic_vector(Dwidth-1 downto 0);
signal	Dout	: std_logic;
begin
	clk<= not clk after 18518ps;

	UUT:Serialiser
	generic map(
		Dwidth =>Dwidth
	)
	port map(
		clk =>clk,
		rst =>rst,
		
		Load =>Load,
		ShiftEn =>ShiftEn,
		Din 	=>Din,
		Dout	=>Dout
	);
	
	main:process
	begin
	rst <= '1';
	Load <= '0';
	ShiftEn <= '0';
	Din <= (others=>'0');
	wait for 100ns;
	rst <= '0';
	wait for 100ns;
	
	wait until rising_edge(clk);
	Load <= '1';
	Din<="10010011";
	wait until rising_edge(clk);
	Load <= '0';
	Din<=x"00";
	
	
	ShiftEnGen:for i in 1 to 8 loop
	    wait for 8.7us;
		wait until rising_edge(clk);
		ShiftEn <= '1';
		wait until rising_edge(clk);
		ShiftEn <= '0';
	end loop;
	
	
	
		wait;
	end process;
	
	

end rtl;