library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity fifo is 
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
end entity;

architecture rtl of fifo is
type mem_type is array(0 to 31) of std_logic_vector(7 downto 0);
signal mem :mem_type ;
signal wr_ptr:std_logic_vector(4 downto 0):=(others => '0');
signal rd_ptr:std_logic_vector(4 downto 0):=(others => '0');
signal count :integer  :=0;
begin

process(clk)
begin
	if(rising_edge(clk)) then
		if(reset='1')then
			data_out<=(others => '0');
			rd_ptr<=(others => '0');
			wr_ptr<=(others => '0');
		elsif((write_en='1') and (full='0'))then
			mem(to_integer(unsigned(wr_ptr)))<=data_in;
			wr_ptr<=wr_ptr+1;
		elsif((read_en='1') and (empty='0'))then
			data_out<=mem(to_integer(unsigned(rd_ptr)));
			rd_ptr<=rd_ptr+1;
		end if;
	end if;
end process;

--handle the count process
	cnt_proc:process(clk)
	begin
		if (rising_edge(clk)) then 
        		if reset ='1' then 
				count <=0;
			elsif write_en ='1' and read_en ='0' then 
				count<=count +1;
			elsif write_en ='0' and read_en ='1' then 
				count<=count -1;
			elsif write_en ='1' and read_en ='1' then 
				count<=count;
			elsif write_en ='0' and read_en ='0' then 
				count<=count;
			end if;
		end if;
	end process cnt_proc;
      --handle fifo flags
      empty <= '1' when count=0 else '0';
      full <= '1' when count=32 else '0';


end rtl;