-- Code your testbench here
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Testbench entity, no ports
entity tb_fifo is
end tb_fifo;

architecture behavior of tb_fifo is
    -- Constants
    constant CLOCK_PERIOD : time := 10 ns;

    -- Signals to connect to the FIFO
    signal clk      : std_logic := '0';
    signal reset    : std_logic := '0';
    signal write_en : std_logic := '0';
    signal read_en  : std_logic := '0';
    signal data_in  : std_logic_vector(7 downto 0) := (others => '0');
    signal data_out : std_logic_vector(7 downto 0);
    signal full     : std_logic;
    signal empty    : std_logic;

    -- Component Declaration for the FIFO
    component fifo is
        port (
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

begin
    -- Instantiate the FIFO component
    uut: fifo
        port map (
            clk      => clk,
            reset    => reset,
            write_en => write_en,
            read_en  => read_en,
            data_in  => data_in,
            data_out => data_out,
            full     => full,
            empty    => empty
        );

    -- Clock generation process
    clk_process : process
    begin
        clk <= '0';
        wait for CLOCK_PERIOD / 2;
        clk <= '1';
        wait for CLOCK_PERIOD / 2;
    end process;

    -- Stimulus process
    stim_proc: process
    begin
        -- Initialize signals
        reset <= '1';
        write_en <= '0';
        read_en <= '0';
        data_in <= (others => '0');
        wait for 10 ns;
        
        -- Release reset
        reset <= '0';
        wait for 10 ns;

--         -- Write data to FIFO
--         write_en <= '1';
--         data_in <= "00000001"; -- Write value 1
--         wait for 10 ns;

--         data_in <= "00000010"; -- Write value 2
--         wait for 10 ns;

--         -- Disable write, enable read
--         write_en <= '0';
--         read_en <= '1';
--         wait for 10 ns;

--         -- Read data from FIFO
--         assert data_out = "00000001" report "Error: FIFO read data mismatch!" severity error;
--         wait for 10 ns;

--         assert data_out = "00000010" report "Error: FIFO read data mismatch!" severity error;
        

--         -- Test empty condition
--         --wait until rising_edge(clk);
--         read_en <= '0';
        
--         wait for 10 ns;


        -- Write more data after read
        write_en <= '1';
        data_in <= "00000100"; -- Write value 4
        wait for 10 ns;
        
        write_en <= '1';
        data_in <= "00100100"; -- Write value 4
        wait for 10 ns;
        
        write_en <= '1';
        data_in <= "10000100"; -- Write value 4
        wait for 10 ns;
        
        write_en <= '1';
        data_in <= "00010100"; -- Write value 4
        wait for 10 ns;
         write_en <= '1';
        data_in <= "00000100"; -- Write value 4
        wait for 10 ns;
        
        write_en <= '1';
        data_in <= "00100100"; -- Write value 4
        wait for 10 ns;
        
        write_en <= '1';
        data_in <= "10000100"; -- Write value 4
        wait for 10 ns;
        
        write_en <= '1';
        data_in <= "00010100"; -- Write value 4
        wait for 10 ns;

 write_en <= '1';
        data_in <= "00000100"; -- Write value 4
        wait for 10 ns;
        
        write_en <= '1';
        data_in <= "00100100"; -- Write value 4
        wait for 10 ns;
        
        write_en <= '1';
        data_in <= "10000100"; -- Write value 4
        wait for 10 ns;
        
        write_en <= '1';
        data_in <= "00010100"; -- Write value 4
        wait for 10 ns;

 write_en <= '1';
        data_in <= "00000100"; -- Write value 4
        wait for 10 ns;
        
        write_en <= '1';
        data_in <= "00100100"; -- Write value 4
        wait for 10 ns;
        
        write_en <= '1';
        data_in <= "10000100"; -- Write value 4
        wait for 10 ns;
        
        write_en <= '1';
        data_in <= "00010100"; -- Write value 4
        wait for 10 ns;
        -- Write more data after read
        write_en <= '1';
        data_in <= "00000100"; -- Write value 4
        wait for 10 ns;
        
        write_en <= '1';
        data_in <= "00100100"; -- Write value 4
        wait for 10 ns;
        
        write_en <= '1';
        data_in <= "10000100"; -- Write value 4
        wait for 10 ns;
        
        write_en <= '1';
        data_in <= "00010100"; -- Write value 4
        wait for 10 ns;
         write_en <= '1';
        data_in <= "00000100"; -- Write value 4
        wait for 10 ns;
        
        write_en <= '1';
        data_in <= "00100100"; -- Write value 4
        wait for 10 ns;
        
        write_en <= '1';
        data_in <= "10000100"; -- Write value 4
        wait for 10 ns;
        
        write_en <= '1';
        data_in <= "00010100"; -- Write value 4
        wait for 10 ns;

 write_en <= '1';
        data_in <= "00000100"; -- Write value 4
        wait for 10 ns;
        
        write_en <= '1';
        data_in <= "00100100"; -- Write value 4
        wait for 10 ns;
        
        write_en <= '1';
        data_in <= "10000100"; -- Write value 4
        wait for 10 ns;
        
        write_en <= '1';
        data_in <= "00010100"; -- Write value 4
        wait for 10 ns;

 write_en <= '1';
        data_in <= "00000100"; -- Write value 4
        wait for 10 ns;
        
        write_en <= '1';
        data_in <= "00100100"; -- Write value 4
        wait for 10 ns;
        
        write_en <= '1';
        data_in <= "10000100"; -- Write value 4
        wait for 10 ns;
        
        write_en <= '1';
        data_in <= "00010100"; -- Write value 4
        wait for 10 ns;
        write_en <= '0';
        wait for 20 ns;

 -- Check FIFO full condition
        assert full = '1' report "Error: FIFO should be full!" severity error;
        wait for 10 ns;

		for i in 0 to 31 loop
        wait until rising_edge(clk);
        read_en <= '1';
        end loop;
        
        wait until rising_edge(clk);
        read_en <= '0';
        
        wait for 40 ns;

        -- End of simulation
        assert false report "End of simulation" severity note;
        std.env.stop;
    end process;

end behavior;
