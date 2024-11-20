--library declaration;
library ieee;
use ieee.std_logic_1164.all;
--entity
entity BaudClkGenerator is
	generic(
		NUMBER_OF_CLOCKS    :integer:=10;
		BAUD_RATE		    :integer:=115200;
		SYS_CLK_FREQ 		:integer:=27000000;
		UART_RX				:boolean:=false  --true if BaudClkGenerator is used in the UART Rx module,false otherwise.
		);
	port(
		Clk :in std_logic;
		Rst :in std_logic;
		
		Start :in std_logic;
		BaudClk :out std_logic;
		Ready	  :out std_logic
		);
end entity;
--architecture
architecture rtl of BaudClkGenerator is
constant BIT_PERIOD 		:integer :=SYS_CLK_FREQ/BAUD_RATE;
constant HALF_BIT_PERIOD 	:integer :=SYS_CLK_FREQ/(2*BAUD_RATE);

signal BitPeriodCounter		:integer range 0 to BIT_PERIOD;
signal clockCount		 	:integer range 0 to NUMBER_OF_CLOCKS;
begin

	bitPeriod_proc:process(clk,rst)
	begin
		if rst='1' then
			BaudClk<='0';
			BitPeriodCounter<=0;
		elsif rising_edge(clk) then
			if clockCount>0 then
				if BitPeriodCounter = BIT_PERIOD then
					BaudClk<='1';
					BitPeriodCounter<=0;
				else
					BaudClk<='0';
					BitPeriodCounter<=BitPeriodCounter+1;
				end if;
			else 
				BaudClk<='0';
				if UART_RX=true then 
				--in the case of receiver mode, we load BitPeriodCounter with HALF_BIT_PERIOD so that the first BaudClk pulse occures 1/2 bit period after asserting the start bit
					BitPeriodCounter<=HALF_BIT_PERIOD;
				else
				--in the case of transmitter mode, we load BitPeriodCounter with 0 so that the first BaudClk pulse occures 1 bit period after asserting the start bit
					BitPeriodCounter<=0;
				end if;
			end if;
		end if;
	end process;
	
	StartCount_proc:process(clk,rst)
	begin
		if rst='1' then
			clockCount<=0;
		elsif rising_edge(clk) then
			if start ='1' then
				clockCount<=NUMBER_OF_CLOCKS;
			elsif baudclk ='1' then
				clockCount<=clockCount-1;
			end if;
		end if;
	end process;
	
	HandleReady_proc:process(clk,rst)
	begin
		if rst='1' then
			ready <='1';
		elsif rising_edge(clk) then
			if start ='1' then
				ready<='0';
			elsif clockCount =0 then
				ready<='1';
			end if;
		end if;
	end process;
	
end rtl;