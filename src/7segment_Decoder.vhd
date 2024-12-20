-- Code your design here
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity segment_Decoder is
	port(
    	clk27 :in std_logic;
        rst :in std_logic;
        data_in :in std_logic_vector(7 downto 0);
    	SW0 : in std_logic_vector(3 downto 0);
        SW1 : in std_logic_vector(3 downto 0);
        SEG_en:out std_logic_vector(3 downto 0);
        Seg1: out std_logic_vector(6 downto 0)
    );

end entity;

architecture rtl of segment_Decoder is
signal one_second_counter: STD_LOGIC_VECTOR (27 downto 0);
-- counter for generating 1-second clock enable
signal one_second_enable: std_logic;
-- one second enable for counting numbers
signal displayed_number: STD_LOGIC_VECTOR (15 downto 0);
signal MSD_7SEG1 :std_logic_vector(6 downto 0);
signal refresh_counter : std_logic_vector(17 downto 0);
signal LED_BCD: STD_LOGIC_VECTOR (3 downto 0):="0000";
signal LED_activating_counter: std_logic_vector(1 downto 0);
begin



PROCESS (LED_BCD)
BEGIN
 -- Case statement implements a logic truth table
 CASE LED_BCD IS
    WHEN "0000" =>
     	MSD_7SEG1 <= "0000001";--0
    WHEN "0001" =>
     	MSD_7SEG1 <= "1001111";--1
    WHEN "0010" =>
     	MSD_7SEG1 <= "0010010";--2
    WHEN "0011" =>
    	MSD_7SEG1 <= "0000110";--3
    WHEN "0100" =>
     	MSD_7SEG1 <= "1001100";--4
    WHEN "0101" =>
     	MSD_7SEG1 <= "0100100";--5
    WHEN "0110" =>
     	MSD_7SEG1 <= "0100000";--6
    WHEN "0111" =>
     	MSD_7SEG1 <= "0001111";--7
    WHEN "1000" =>
     	MSD_7SEG1 <= "0000000";--8
    WHEN "1001" =>
     	MSD_7SEG1 <= "0000100";--9
	WHEN "1010" =>
     	MSD_7SEG1 <= "0000010";--a
    WHEN "1011" =>
     	MSD_7SEG1 <= "1100000";--b
    WHEN "1100" =>
     	MSD_7SEG1 <= "0110001";--c
    WHEN "1101" =>
     	MSD_7SEG1 <= "1000010";--d
    WHEN "1110" =>
     	MSD_7SEG1 <= "0110000";--e
    WHEN "1111" =>
     	MSD_7SEG1 <= "0111000";--f
    WHEN OTHERS =>
     	MSD_7SEG1 <= "1000001";--others
END CASE; 
end process;

process(clk27,rst)
begin
	if(rst='1') then
        refresh_counter <= (others => '0');
    elsif(rising_edge(clk27)) then
        refresh_counter <= refresh_counter + 1;
    end if;
end process;
LED_activating_counter <= refresh_counter(17 downto 16);

Seg1<=  not MSD_7SEG1;

process(LED_activating_counter,SW0,SW1,data_in)
begin
    case LED_activating_counter is
    when "00" =>
        SEG_en <= "0111"; 
        -- activate LED1 and Deactivate LED2, LED3, LED4
        LED_BCD <= SW1;
        -- the first hex digit of the 16-bit number
    when "01" =>
        SEG_en <= "1011"; 
        -- activate LED2 and Deactivate LED1, LED3, LED4
        LED_BCD <= SW0;
        -- the second hex digit of the 16-bit number
    when "10" =>
        SEG_en <= "1101"; 
        -- activate LED3 and Deactivate LED2, LED1, LED4
        LED_BCD <= data_in(3 downto 0);
        -- the third hex digit of the 16-bit number
    when "11" =>
        SEG_en <= "1110"; 
        -- activate LED4 and Deactivate LED2, LED3, LED1
        LED_BCD <= data_in(7 downto 4);
        -- the fourth hex digit of the 16-bit number    
    end case;
end process;

-- Counting the number to be displayed on 4-digit 7-segment Display 
-- on Basys 3 FPGA board
process(clk27, rst)
begin
        if(rst='1') then
            one_second_counter <= (others => '0');
        elsif(rising_edge(clk27)) then
            if(one_second_counter>=x"19BFCDA") then
                one_second_counter <= (others => '0');
            else
                one_second_counter <= one_second_counter + "0000001";
            end if;
        end if;
end process;
one_second_enable <= '1' when one_second_counter=x"19BFCDA" else '0';
process(clk27, rst)
begin
        if(rst='1') then
            displayed_number <= (others => '0');
        elsif(rising_edge(clk27)) then
             if(one_second_enable='1') then
                displayed_number <= displayed_number + x"0001";
             end if;
        end if;
end process;

end rtl;