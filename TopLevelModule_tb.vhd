--library declaration
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--entity
entity TopLevelModule_tb is
		generic(
			RS232_DATA_BITS		:integer:=8

		);

end entity;

--architecture
architecture rtl of TopLevelModule_tb is

	component TopLevelModule is
		generic(
			RS232_DATA_BITS		:integer:=8;
			BAUD_RATE		  	:integer:=115200;
			SYS_CLK_FREQ 	 	:integer:=27000000
		);
		port(
			clk				:in std_logic;
			Rst				:in std_logic;
			
			--RS232 ports
			rs232_rx_pin		:in std_logic;
			rs232_tx_pin		:out std_logic;
			--Switches ports
			SW0                 :in std_logic_vector(3 downto 0);
			SW1                 :in std_logic_vector(3 downto 0);
			--4_7segment ports
			Segment             :out std_logic_vector(6 downto 0);
			Seg_en              :out std_logic_vector(3 downto 0);
			--fifo rd,wr,leds
			full_led            :out std_logic;
			empty_led           :out std_logic;
			btn_wr              :in std_logic;
			btn_rd              :in std_logic
			
		);

	end component;
signal			clk				: std_logic:='0';
signal			Rst				:std_logic;
			
			--RS232 ports
signal			rs232_rx_pin		:std_logic;
signal			rs232_tx_pin		: std_logic;
signal 			TransmittedData		:std_logic_vector(RS232_DATA_BITS-1 downto 0);
signal 			FinalTransmittedData		:std_logic_vector(RS232_DATA_BITS-1 downto 0);

begin


	clk <= not clk after 18.5ns;
	
	UUT_TopLevelModule:TopLevelModule 
		generic map(
			RS232_DATA_BITS		=>RS232_DATA_BITS,
			BAUD_RATE		  	=>115200,
			SYS_CLK_FREQ 	 	=>27000000
		)
		port map(
			clk					=>clk,
			Rst					=>Rst,
			
			--RS232 ports
			rs232_rx_pin		=>rs232_rx_pin,
			rs232_tx_pin		=>rs232_tx_pin,
			--Switches ports
			SW0                 =>SW0,
			SW1                 =>SW1,
			--4_7segment ports
			Segment             =>Segment,
			Seg_en              =>Seg_en,
			--fifo rd,wr,leds
			full_led            =>full_led,
			empty_led           =>empty_led,
			btn_wr              =>btn_wr,
			btn_rd              =>btn_rd,
			
		);
		
	
	
	testProcess:process
		begin
	
	rst<='1';
	rs232_rx_pin<='1';
	wait for 100ns;
	rst<='0';
	wait for 100ns;
	
	
	
	
		wait;
	end process;

	
end rtl;