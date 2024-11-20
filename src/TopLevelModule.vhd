--library declaration
library ieee;
use ieee.std_logic_1164.all;

--entity
entity TopLevelModule is
	generic(
		RS232_DATA_BITS		:integer:=8;
		BAUD_RATE		  	:integer:=115200;
		SYS_CLK_FREQ 	 	:integer:=27000000;
        IDLE_STATE          :std_logic:='0'
	);
	port(
		clk				:in std_logic;
		Rst				:in std_logic;
		
		--RS232 ports
		rs232_rx_pin		:in std_logic;
		rs232_tx_pin		:out std_logic;
        --Switches ports
        Row_Pins            : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
        Col_Pins            : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
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

end entity;

--architecture
architecture rtl of TopLevelModule is
	
	component UART_tx is
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
	end component;
	
	component UART_rx is
	generic(
		RS232_DATA_BITS		:integer;
		BAUD_RATE		  	:integer;
		SYS_CLK_FREQ 	 	:integer
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
	end component;

    component fifo is 
    port(
            clk      : in std_logic;
            reset    : in std_logic;
            write_en : in std_logic;
            read_en  : in std_logic;
            data_in  : in std_logic_vector(7 downto 0);
            data_out : out std_logic_vector(7 downto 0);
            full     : out std_logic;
            empty    : out std_logic
        );
    end component;

    component segment_Decoder is
	port(
    	clk27 :in std_logic;
        rst :in std_logic;
        data_in :in std_logic_vector(7 downto 0);
    	SW0 : in std_logic_vector(3 downto 0);
        SW1 : in std_logic_vector(3 downto 0);
        SEG_en:out std_logic_vector(3 downto 0);
        Seg1: out std_logic_vector(6 downto 0)
    );
    end component;

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
    component debouncer is
	port(
	clk         : in std_logic;
    rst         : in std_logic;
    SW_in       : in std_logic;
	SW_OUT      :out std_logic
    );
    end component;

    component WS2812 is 
	port(
		clk 		:in std_logic;
		empty_flag	:in std_logic;
		full_flag	:in std_logic;
		ws2812_out	:out std_logic
	);
    end component;

    component Key_Pad IS
    PORT (
        Reset_In    : IN  STD_LOGIC;
        Clock_In    : IN  STD_LOGIC;
        Row_Pins    : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
        Col_Pins    : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
        data_out    : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
    );
    END component;


type state_type is (IDLE,data_toTXData,START_TRANSMITTER);
signal SMVariable :state_type;
signal TxStart 			: std_logic;
signal TxReady 			: std_logic;
signal RxIRQ 			: std_logic;
signal RxIRQClear       : std_logic;
signal RxData 			: std_logic_vector(RS232_DATA_BITS-1 downto 0);
signal TxData    : std_logic_vector(RS232_DATA_BITS-1 downto 0);
signal fifo_tx_data_out    : std_logic_vector(RS232_DATA_BITS-1 downto 0);
signal fifo_rx_data_out    : std_logic_vector(RS232_DATA_BITS-1 downto 0);
signal tx_fifo_empty        : std_logic;
signal rx_fifo_full        : std_logic;
signal  rx_write_en           :std_logic;
signal  rx_read_en           :std_logic:='0';
signal  tx_read_en           :std_logic:='0';
signal wr_en_fallingEdge   :std_logic;
signal wr_en_Delay:std_logic;
signal btn_wr_Synced        : std_logic;
signal btn_wr_debounced        : std_logic :='0';
signal btn_rd_Synced        : std_logic;
signal btn_rd_debounced        : std_logic :='0';
signal rx_full_led        : std_logic;
signal rx_empty_led        : std_logic;
signal KeyP_data_out        : std_logic_vector(7 downto 0);
signal rst_n        : std_logic;
begin
    rst_n<=not rst;
	inst_UART_tx:UART_tx 
	generic map(
		RS232_DATA_BITS		=>RS232_DATA_BITS,
		BAUD_RATE		  	=>BAUD_RATE,
		SYS_CLK_FREQ 	 	=>SYS_CLK_FREQ
	)
	port map(
		clk 			=>clk,
		rst 			=>rst_n,
		
		TxStart 		=>TxStart,
		TxData 			=>TxData,
		TxReady 		=>TxReady,
		UART_tx_pin		=>(rs232_tx_pin)
	);
    TxData<=fifo_tx_data_out;
	inst_UART_rx:UART_rx
	generic map(
		RS232_DATA_BITS		=>RS232_DATA_BITS,
		BAUD_RATE		  	=>BAUD_RATE,
		SYS_CLK_FREQ 	 	=>SYS_CLK_FREQ
	)
	port map(
		clk				 =>clk,
		Rst				 =>rst_n,
		RS232_Rx		 =>(rs232_rx_pin ),--Serial Asynchronous signal
		RxIRQClear		 =>RxIRQClear,
		RxIRQ			 =>RxIRQ,
        rx_rd_ptr		 =>rx_write_en,
		RxData			 =>RxData
	);

    inst_FIFO_rx:fifo
    port map(
            clk      =>clk,
            reset    =>rst_n,
            write_en =>rx_write_en,
            read_en  => rx_read_en,
            data_in  =>RxData,
            data_out =>FIFO_rx_Data_out,
            full     =>rx_full_led,
            empty    => rx_empty_led
        );

    inst_FIFO_tx:fifo
    port map(
            clk      =>clk,
            reset    =>rst_n,
            write_en =>btn_wr_debounced,
            read_en  =>tx_read_en,
            data_in  =>KeyP_data_out,
            data_out =>FIFO_tx_Data_out,
            full     =>tx_full_led,
            empty    =>tx_fifo_empty
        );    
    
    inst_SegDec:segment_Decoder
	port map(
    	clk27       =>clk,
        rst         =>rst_n,
        data_in     =>FIFO_rx_Data_out,
    	SW0         =>KeyP_data_out(3 downto 0),
        SW1         =>KeyP_data_out(7 downto 4),
        SEG_en      =>SEG_en,
        Seg1        =>Segment
    );
    
    inst_sync_rdBtn: Synchroniser
	generic map(
		IDLE_STATE =>IDLE_STATE
	)
	port map(
		clk         =>clk,
		Rst         =>rst_n,
		Async       =>btn_rd,
		Synced      =>btn_rd_Synced
	);
    
    inst_sync_wrBtn: Synchroniser
	generic map(
		IDLE_STATE =>IDLE_STATE
	)
	port map(
		clk         =>clk,
		Rst         =>rst_n,
		Async       =>btn_wr,
		Synced      =>btn_wr_Synced
	);
    
    inst_wrBtn_Deb: debouncer 
	port map(
	clk         =>clk,
    rst         =>rst_n,
    SW_in       =>btn_wr_Synced,
	SW_OUT      =>btn_wr_debounced
    );

    inst_rdBtn_Deb: debouncer 
	port map(
	clk         =>clk,
    rst         =>rst_n,
    SW_in       =>btn_rd_Synced,
	SW_OUT      =>btn_rd_debounced
    );
    
    inst_ws2812 :WS2812 
	port map(
		clk 		=>clk,
		empty_flag	=>rx_empty_led,
		full_flag	=>rx_full_led,
		ws2812_out	=>ws2812_out_rx
	);

    inst_keyPad : Key_Pad 
    PORT map(
        Reset_In    =>rst_n,
        Clock_In    =>clk,
        Row_Pins    =>Row_Pins,
        Col_Pins    =>Col_Pins,
        data_out    =>KeyP_data_out
    );
    
	rx_read_en<=btn_rd_debounced;
	tx_empty_led<=tx_fifo_empty;

    tx_fifo_wr_en_FallingEdgeDetector :process(clk,rst_n)
	begin
		if rst_n='1' then 
			wr_en_fallingEdge<='0';
			wr_en_Delay <='1';
		elsif rising_edge(clk) then
			wr_en_Delay <=btn_wr_debounced;
				if btn_wr_debounced ='0' and wr_en_Delay='1' then
					wr_en_fallingEdge<='1';
				else
					wr_en_fallingEdge<='0';
				end if;
		end if;
    end process;

    
	SM_proc:process(clk,rst_n)
	begin
		if rst_n='1' then 
			TxStart<='0';
			SMVariable <=IDLE;
		elsif rising_edge(clk) then
		
			case SMVariable is
				When IDLE => 
					if tx_fifo_empty='0' and TxReady='1' and btn_wr_debounced='0' and wr_en_fallingEdge='0' and wr_en_Delay='0' then
						SMVariable<=data_toTXData;
                        tx_read_en<='1';
                    else SMVariable <=IDLE;
                    end if;
                            
				When data_toTXData => 
                        tx_read_en<='0';
						SMVariable<=START_TRANSMITTER;
						TxStart<= not tx_FIFO_empty;
                   
					
					
				When START_TRANSMITTER =>
					TxStart<='0';
					SMVariable <=IDLE;
					
				when others=>
					SMVariable <=IDLE;
			end case;
		
		end if;
	end process;
	
end rtl;