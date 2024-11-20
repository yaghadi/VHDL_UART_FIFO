--library decalration
library ieee;
use ieee.std_logic_1164.all;
--entity 
entity ShiftRegister_tb is
	generic(
		DOUT_WIDTH : integer:=8;
		SHIFT_DIR : character:='R' -- 'L' generates a shift to the left and 'R' generate a shift to the right
	);
end entity;

architecture rtl of ShiftRegister_tb is

	component ShiftRegister is
	generic(
		DOUT_WIDTH : integer;
		SHIFT_DIR : character -- 'L' generates a shift to the left and 'R' generate a shift to the right
	);
	port(
		clk : in std_logic;
		rst : in std_logic;
		
		ShiftEn :in std_logic;
		Din 	:in std_logic;
		Dout :out std_logic_vector(DOUT_WIDTH-1 downto 0)
	);
	end component;
signal		clk :  std_logic:='0';
signal		rst :  std_logic;
		
signal		ShiftEn :std_logic;
signal		Din 	: std_logic;
signal		Dout : std_logic_vector(DOUT_WIDTH-1 downto 0);
constant    temp_din:std_logic_vector(DOUT_WIDTH-1 downto 0):=x"51";
begin
	clk <= not clk after 18.5ns;
	
	ShiftRegister_INST : ShiftRegister
	generic map(
		DOUT_WIDTH =>DOUT_WIDTH,
		SHIFT_DIR =>SHIFT_DIR    -- 'L' generates a shift to the left and 'R' generate a shift to the right
	)
	port map(
		clk =>clk,
		rst =>rst,
		
		ShiftEn =>ShiftEn,
		Din 	=>Din,
		Dout =>Dout
	);
	
	
	testBench:process
	begin
	
	
	rst<='1';
	ShiftEn<='0';
	wait for 100ns;
	rst<='0';
	wait for 100ns;
	
	for i in 0 to 7 loop
		Din<=temp_din(i);
		wait for 4.3us;
		wait until rising_edge(clk);
		ShiftEn <= '1';
		
		wait until rising_edge(clk);
		ShiftEn <= '0';
		wait for 4.3us;
	end loop;
	
	
	
		wait;
	end process;

end rtl;