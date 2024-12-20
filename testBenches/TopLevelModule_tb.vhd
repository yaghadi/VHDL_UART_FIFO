--library declaration
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

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
			tx_full_led            :out std_logic;
			tx_empty_led           :out std_logic;
			ws2812_out_rx           :out std_logic;
			btn_wr              :in std_logic;
			btn_rd              :in std_logic

			
		);

	end component;
signal			clk				: std_logic:='0';
signal			Rst				:std_logic;
			
			--RS232 ports
signal			rs232_rx_pin		:std_logic;
signal			rs232_tx_pin		: std_logic;
			--Switches ports
signal			SW0                 : std_logic_vector(3 downto 0);
signal			SW1                 : std_logic_vector(3 downto 0);
			--4_7segment ports
signal			Segment             : std_logic_vector(6 downto 0);
signal			Seg_en              : std_logic_vector(3 downto 0);
			--fifo rd,wr,leds
signal			tx_full_led            : std_logic;
signal			tx_empty_led           : std_logic;
signal		    ws2812_out_rx           : std_logic;

signal			btn_wr              : std_logic;
signal			btn_rd              : std_logic;
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
			tx_full_led            =>tx_full_led,
			tx_empty_led           =>tx_empty_led,
			ws2812_out_rx            =>ws2812_out_rx,
			btn_wr              =>btn_wr,
			btn_rd              =>btn_rd
			
		);
		
	
	
		
	
	testProcess:process
		variable TrasnmitDataVector :std_logic_vector(RS232_DATA_BITS-1 downto 0);
		procedure TRANSMIT_CHARACTER
		(
			constant TransmitData :in integer
			
		)is
		begin
			TrasnmitDataVector:=std_logic_vector(to_unsigned(TransmitData,RS232_DATA_BITS));
			
			rs232_rx_pin<='0';--transmitting the start bit
			wait for 8.7us;
			-- transmitting data LSB first
			for i in 1 to RS232_DATA_BITS loop 
				rs232_rx_pin<=TrasnmitDataVector(i-1);
				wait for 8.7us;
			end loop;
			rs232_rx_pin<='1';--transmitting the stop bit
			wait for 8.7us;
		
		end procedure;
	begin
	
	rst<='1';
	rs232_rx_pin<='1';
	btn_rd<='0';
	btn_wr<='0';
	wait for 100ns;
	rst<='0';
	wait for 100ns;
	
	for i in 0 to 31 loop
		TRANSMIT_CHARACTER(i);
		wait for 20us;
	end loop;

	wait for 100 ns;
	
	for i in 0 to 31 loop
		wait until rising_edge(clk);
		btn_rd<='1';
		wait until rising_edge(clk);
		btn_rd<='0';
	end loop;
	wait for 100 ns;
	SW0<="0011";
	SW1<="1111";
	for i in 0 to 31 loop
	wait until rising_edge(clk);
	btn_wr<='1';
	wait until rising_edge(clk);
	btn_wr<='0';
	end loop;
	wait for 3 ms;
	rst<='1';
	rs232_rx_pin<='1';
	btn_rd<='0';
	btn_wr<='0';
	wait for 100ns;
	rst<='0';
	wait for 100ns;
	
	for i in 0 to 31 loop
		TRANSMIT_CHARACTER(i);
		wait for 20us;
	end loop;
	wait for 100 ns;
	for i in 0 to 31 loop
		wait until rising_edge(clk);
		btn_rd<='1';
		wait until rising_edge(clk);
		btn_rd<='0';
	end loop;
	
	for i in 1 to 10 loop
	SW0<=std_logic_vector(to_unsigned(i-1,4));
	SW1<=std_logic_vector(to_unsigned(i+1,4));
	wait until rising_edge(clk);
	btn_wr<='1';
	wait until rising_edge(clk);
	btn_wr<='0';
	end loop;

	
	
		wait;
	end process;

	
end rtl;