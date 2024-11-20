LIBRARY ieee;
USE ieee.STD_LOGIC_1164.ALL;
USE ieee.STD_LOGIC_ARITH.ALL;
USE ieee.STD_LOGIC_UNSIGNED.ALL;

ENTITY Key_Pad IS
    PORT (
        Reset_In    : IN  STD_LOGIC;
        Clock_In    : IN  STD_LOGIC;
        Row_Pins    : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
        Col_Pins    : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
        data_out    : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
    );
END Key_Pad;

ARCHITECTURE Key_Pad_RTL OF Key_Pad IS

    -- Constants
    CONSTANT SCAN_INTERVAL : INTEGER := 27000;  -- 27 MHz / 1 kHz = 50,000
    CONSTANT DEBOUNCE_TIME : INTEGER := 10;     -- 10 ms debounce count

    -- Signals
    SIGNAL scan_counter     : INTEGER RANGE 0 TO SCAN_INTERVAL - 1 := 0;
    SIGNAL debounce_counter : INTEGER RANGE 0 TO DEBOUNCE_TIME - 1 := 0;
    SIGNAL debounce_active  : STD_LOGIC := '0'; -- Active when debouncing
    SIGNAL stable_key       : STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0');
    SIGNAL data_out_temp    : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');
    SIGNAL Count            : STD_LOGIC_VECTOR(23 DOWNTO 0);
    TYPE Key_State          IS (Col_Pins1, Col_Pins2, Col_Pins3, Col_Pins4);
    SIGNAL System_State     : Key_State := Col_Pins1;

    -- Key lookup table
    TYPE Key_Lookup IS ARRAY (0 TO 15) OF STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL Key_Lookup_Data : Key_Lookup := (
        X"30", X"31", X"32", X"33",
        X"34", X"35", X"36", X"37",
        X"38", X"39", X"0a", X"0b",
        X"0c", X"0d", X"0e", X"0f"
    );

BEGIN

    -- 1 kHz Scan Control Process
    PROCESS(Clock_In)
    BEGIN
        IF rising_edge(Clock_In) THEN
            IF scan_counter < SCAN_INTERVAL - 1 THEN
                scan_counter <= scan_counter + 1;
            ELSE
                scan_counter <= 0;
                -- Trigger a new scan only every 1 ms
                CASE System_State IS
                    WHEN Col_Pins1 =>
                        Col_Pins <= "0001";
                        stable_key <= Row_Pins;
                        System_State <= Col_Pins2;

                    WHEN Col_Pins2 =>
                        Col_Pins <= "0010";
                        stable_key <= Row_Pins;
                        System_State <= Col_Pins3;

                    WHEN Col_Pins3 =>
                        Col_Pins <= "0100";
                        stable_key <= Row_Pins;
                        System_State <= Col_Pins4;

                    WHEN Col_Pins4 =>
                        Col_Pins <= "1000";
                        stable_key <= Row_Pins;
                        System_State <= Col_Pins1;
                END CASE;
            END IF;
        END IF;
    END PROCESS;

    -- Debounce Logic
    PROCESS(Clock_In)
    BEGIN
        IF rising_edge(Clock_In) THEN
            IF stable_key /= Row_Pins THEN
                debounce_counter <= 0; -- Key press changed, reset debounce
                debounce_active <= '1';
            ELSIF debounce_active = '1' THEN
                IF debounce_counter < DEBOUNCE_TIME - 1 THEN
                    debounce_counter <= debounce_counter + 1;
                ELSE
                    debounce_counter <= 0;
                    debounce_active <= '0'; -- Key press is stable
                    CASE Col_Pins & Row_Pins IS
                        WHEN "0001" & not"0001" => data_out_temp <= Key_Lookup_Data(0);
                        WHEN "0001" & not"0010" => data_out_temp <= Key_Lookup_Data(1);
                        WHEN "0001" & not"0100" => data_out_temp <= Key_Lookup_Data(2);
                        WHEN "0001" & not"1000" => data_out_temp <= Key_Lookup_Data(3);
                        WHEN "0010" & not"0001" => data_out_temp <= Key_Lookup_Data(4);
                        WHEN "0010" & not"0010" => data_out_temp <= Key_Lookup_Data(5);
                        WHEN "0010" & not"0100" => data_out_temp <= Key_Lookup_Data(6);
                        WHEN "0010" & not"1000" => data_out_temp <= Key_Lookup_Data(7);
                        WHEN "1000" & not"0001" => data_out_temp <= Key_Lookup_Data(8);
                        WHEN "1000" & not"0010" => data_out_temp <= Key_Lookup_Data(9);
                        WHEN "1000" & not"0100" => data_out_temp <= Key_Lookup_Data(10);
                        WHEN "1000" & not"1000" => data_out_temp <= Key_Lookup_Data(11);
                        WHEN "0100" & not"0001" => data_out_temp <= Key_Lookup_Data(12);
                        WHEN "0100" & not"0010" => data_out_temp <= Key_Lookup_Data(13);
                        WHEN "0100" & not"0100" => data_out_temp <= Key_Lookup_Data(14);
                        WHEN "0100" & not"1000" => data_out_temp <= Key_Lookup_Data(15);
                        WHEN OTHERS => data_out_temp <= data_out_temp;
                    END CASE;
                END IF;
            END IF;
        END IF;
    END PROCESS;

    -- Assign output
    data_out <= data_out_temp;

END Key_Pad_RTL;
