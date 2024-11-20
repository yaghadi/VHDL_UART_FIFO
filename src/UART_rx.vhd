--library declaration
library ieee;
use ieee.std_logic_1164.all;

--entity
entity UART_rx is
	generic(
		RS232_DATA_BITS		:integer:=8;
		BAUD_RATE		  	:integer:=115200;
		SYS_CLK_FREQ 	 	:integer:=27000000
	);
	port(
		clk				:in std_logic;
		Rst				:in std_logic;
		RS232_Rx		:in std_logic;--Serial Asynchronous signal
		RxIRQClear		:in std_logic;
		RxIRQ			:out std_logic;
		rx_rd_ptr		:out std_logic;
		RxData			:out std_logic_vector(RS232_DATA_BITS-1 downto 0)
	);

end entity;

--architecture
architecture rtl of UART_rx is
	constant	SHIFT_DIR 			: character:='R';
	constant	IDLE_STATE			:std_logic:='1';
	constant	NUMBER_OF_CLOCKS  	:integer:=9;

	component ShiftRegister is
	generic(
		DOUT_WIDTH : integer;
		SHIFT_DIR : character -- 'L' generates a shift to the left and 'R' generate a shift to the right
	);
	port(
		clk 				: in std_logic;
		rst 				: in std_logic;
		
		ShiftEn 			:in std_logic;
		Din 				:in std_logic;
		Dout 				:out std_logic_vector(DOUT_WIDTH-1 downto 0)
	);
	end component;
	
	component Synchroniser is
	generic(
		IDLE_STATE :std_logic
	);
	port(
		clk					:in std_logic;
		Rst					:in std_logic;
		Async				:in std_logic;
		Synced				:out std_logic
	);

	end component;
	component BaudClkGenerator is
	generic(
		NUMBER_OF_CLOCKS  	:integer;
		BAUD_RATE		   	:integer;
		SYS_CLK_FREQ  		:integer;
		UART_RX				:boolean --true if BaudClkGenerator is used in the UART Rx module,false otherwise.
		);
	port(
		Clk 				:in std_logic;
		Rst 				:in std_logic;
		
		Start 				:in std_logic;
		BaudClk 			:out std_logic;
		Ready	  			:out std_logic
		);
	end component;
	
	
	--state machine variable
	type state_type is (IDLE,COLLECT_RS232_DATA,ASSERT_IRQ);
	signal SMVariable :STATE_TYPE;
	signal Start		 			:std_logic;
	signal Ready 					:std_logic:='1';
	signal BaudClk 					:std_logic;
	signal fallingEdge 				:std_logic;
	signal RS232_Rx_Synched_Delay 	:std_logic;
	signal RS232_Rx_Synched 		:std_logic;
begin
	
	ShiftRegister_INST:ShiftRegister
	generic map(
		DOUT_WIDTH => RS232_DATA_BITS,
		SHIFT_DIR =>SHIFT_DIR -- 'L' generates a shift to the left and 'R' generate a shift to the right
	)
	port map(
		clk 		=>clk,
		Rst 		=>rst,
		
		ShiftEn 	=>BaudClk,
		Din 		=>RS232_Rx_Synched,
		Dout 		=>RxData
	);

	
	Synchroniser_INST : Synchroniser 
	generic map(
		IDLE_STATE =>IDLE_STATE
	)
	port map(
		clk			=>clk,
		Rst			=>rst,
		Async		=>RS232_RX,
		Synced		=>RS232_Rx_Synched
	);

	BaudClkGenerator_RX_INST :BaudClkGenerator
	generic map(
		NUMBER_OF_CLOCKS  =>NUMBER_OF_CLOCKS,
		BAUD_RATE		  =>BAUD_RATE,
		SYS_CLK_FREQ  	  =>SYS_CLK_FREQ,
		UART_RX			  =>true
	)
	port map(
		Clk 		=>clk,
		Rst 		=>rst,
		
		Start 	=>Start,
		BaudClk =>BaudClk,
		Ready	=>Ready
		);
	
	RS232_FallingEdgeDetector :process(clk,rst)
	begin
		if rst='1' then 
			fallingEdge<='0';
			RS232_Rx_Synched_Delay <='1';
		elsif rising_edge(clk) then
			RS232_Rx_Synched_Delay <=RS232_Rx_Synched;
				if RS232_Rx_Synched ='0' and RS232_Rx_Synched_Delay='1' then
					fallingEdge<='1';
				else
					fallingEdge<='0';
				end if;
		end if;
	
	end process;
	
	RXStateMachine :process(clk,rst)
	begin
		if rst='1' then 
			Start<='0';
			RxIRQ<='0';
			rx_rd_ptr<='0';		
			SMVariable<=IDLE;
		elsif rising_edge(clk) then
			if RxIRQClear='1' then
				RxIRQ<='0';
			end if;
			case SMVariable is
				when IDLE=>
					if fallingEdge ='1' then
						Start<='1';
					else 
						Start<='0';
					end if;
					if Ready ='0' then 
						SMVariable<=COLLECT_RS232_DATA;
					end if;
					
				when COLLECT_RS232_DATA =>
					Start<='0';
					if Ready ='1' then
						rx_rd_ptr<='1';	 
						SMVariable<=ASSERT_IRQ;
					end if;
				when ASSERT_IRQ=>	
						rx_rd_ptr<='0';	
						RxIRQ <='1' ;
						SMVariable<=IDLE;
				when others =>
					SMVariable<=IDLE;
			end case;
		end if;
	
	end process;
end rtl;