--library decalration
library ieee;
use ieee.std_logic_1164.all;
--entity 
entity UART_tx is
	generic(
		RS232_DATA_BITS :integer;
		SYS_CLK_FREQ :integer;
		BAUD_RATE : integer
	);
	port(
		clk : in std_logic;
		rst : in std_logic;
		
		TxStart :in std_logic;
		TxData 	:in std_logic_vector(RS232_DATA_BITS-1 downto 0);
		TxReady :out std_logic;
		UART_tx_pin	:out std_logic
	);
end entity;

architecture rtl of UART_tx is
	

	component BaudClkGenerator is
	generic(
		NUMBER_OF_CLOCKS  :integer;
		BAUD_RATE		   :integer;
		SYS_CLK_FREQ  :integer;
		UART_RX				:boolean --true if BaudClkGenerator is used in the UART Rx module,false otherwise.
		);
	port(
		Clk :in std_logic;
		Rst :in std_logic;
		
		Start :in std_logic;
		BaudClk :out std_logic;
		Ready	  :out std_logic
		);
	end component;	
	component Serialiser is
	generic(
		Dwidth  :integer
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
	
signal BaudClk :std_logic;

signal TxPacket :std_logic_vector(RS232_DATA_BITS+1 downto 0);
begin

	TxPacket <= '1' & TxData & '0';
	
	
	UART_Serialiser_INST:Serialiser
	generic map(
		Dwidth =>RS232_DATA_BITS+2
	)
	port map(
		clk =>clk,
		rst =>rst,
		
		Load 	=>TxStart,
		ShiftEn =>BaudClk,
		Din 	=>TxPacket,
		Dout	=>UART_tx_pin
	);
	
	UART_TIMING_INST :BaudClkGenerator
	generic map(
		NUMBER_OF_CLOCKS  =>RS232_DATA_BITS+2,
		BAUD_RATE		  =>BAUD_RATE,
		SYS_CLK_FREQ  	  =>SYS_CLK_FREQ,
		UART_RX			  =>false
		)
	port map(
		Clk => Clk,
		Rst => Rst,
		
		Start     =>TxStart,
		BaudClk   =>BaudClk,
		Ready	  =>TxReady
		);
		
		
		

end rtl;