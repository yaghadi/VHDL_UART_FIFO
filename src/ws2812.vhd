library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
--entity
entity WS2812 is 
	port(
		clk 		:in std_logic;
		empty_flag	:in std_logic;
		full_flag	:in std_logic;
		ws2812_out	:out std_logic
	);
end entity;


--architecture
architecture rtl of WS2812 is
constant ws2812_num 			: integer :=0;--LED number of ws2812(starts from 0)
constant ws2812_width 			: integer :=24;--ws2812 data bit width
constant clk_fre 				: integer :=27000000; --clk frequency(MHz)

constant DELAY_1_HIGH 			: integer := integer(real(clk_fre) / 1_000_000.0 * 0.85) - 1;--≈850ns±150ns     1 high level time
constant DELAY_1_LOW			: integer := integer(real(clk_fre) / 1_000_000.0 * 0.40) - 1;--≈400ns±150ns 	 1 low level time
constant DELAY_0_HIGH 			: integer := integer(real(clk_fre) / 1_000_000.0 * 0.40) - 1;--≈400ns±150ns 	 0 high level time
constant DELAY_0_LOW 			: integer := integer(real(clk_fre) / 1_000_000.0 * 0.85) - 1;--≈850ns±150ns     0 low level time
constant DELAY_RESET 			: integer := integer(real(clk_fre) / 10.0) - 1;--0.1s reset time ＞50us

type state_type is (RESET,DATA_SEND_GO,BIT_SEND_HIGH,BIT_SEND_LOW);
signal state :state_type;

-- LED data (24 bits: BRG format, Red only)
signal red_light 				: std_logic_vector(23 downto 0) := "000000001111111100000000";
signal green_light 				: std_logic_vector(23 downto 0) := "000000000000000011111111";
signal no_light 				: std_logic_vector(23 downto 0) := "000000000000000000000000";

signal bit_send					: std_logic_vector(8 downto 0) :=(others => '0');
signal data_send				: std_logic_vector(8 downto 0) :=(others => '0');
signal clk_count				: std_logic_vector(31 downto 0) :=(others => '0');
signal WS2812_data				: std_logic_vector(23 downto 0) :=(others => '0');


begin

process(clk)
begin
	if rising_edge(clk) then
		case state is 
			when RESET =>
				ws2812_out<='0';
				if clk_count < DELAY_RESET then
					clk_count<=clk_count+1;
				else
					clk_count<=(others =>'0');
					WS2812_data <= green_light when empty_flag = '1' else red_light when full_flag = '1' else no_light;
					state<=DATA_SEND_GO;
				end if;
			when DATA_SEND_GO =>
				if((data_send > WS2812_NUM) and (bit_send=WS2812_width)) then
					clk_count<=(others =>'0');
					bit_send<=(others =>'0');
					data_send<=(others =>'0');
					state<=RESET;
				elsif bit_send <ws2812_width then
					state<=BIT_SEND_HIGH;
				else 
					data_send<=data_send+1;
					bit_send<=(others =>'0');
					state<=BIT_SEND_HIGH;
				end if;
			when BIT_SEND_HIGH =>
				ws2812_out<='1';
				if WS2812_data(to_integer(unsigned(bit_send))) then
					if clk_count < DELAY_1_HIGH then
						clk_count<=clk_count+1;
					else
						clk_count<=(others =>'0');
						state<=BIT_SEND_LOW;
					end if;
				else
					if clk_count < DELAY_0_HIGH then
						clk_count<=clk_count+1;
					else
						clk_count<=(others =>'0');
						state<=BIT_SEND_LOW;
					end if;
				end if;
			when BIT_SEND_LOW =>
				ws2812_out<='0';
				if WS2812_data(to_integer(unsigned(bit_send))) then
					if clk_count < DELAY_1_LOW then
						clk_count<=clk_count+1;
					else
						clk_count<=(others =>'0');
						bit_send <= bit_send+1;
						state<=DATA_SEND_GO;
					end if;
				else
					if clk_count < DELAY_0_LOW then
						clk_count<=clk_count+1;
					else
						clk_count<=(others =>'0');
						bit_send <= bit_send+1;
						state<=DATA_SEND_GO;
					end if;
				end if;
		end case;
	end if;
end process;





end rtl;