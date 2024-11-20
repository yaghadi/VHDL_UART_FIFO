--library decalration
library ieee;
use ieee.std_logic_1164.all;
--entity 
entity Serialiser is
	generic(
		Dwidth :integer
	);
	port(
		clk : in std_logic;
		rst : in std_logic;
		
		Load :in std_logic;
		ShiftEn :in std_logic;
		Din 	:in std_logic_vector(Dwidth-1 downto 0);
		Dout	:out std_logic
	);
		
end entity;
--architecture
architecture rtl of Serialiser is
signal ShiftReg :std_logic_vector(Dwidth-1 downto 0);

begin
	SerialiserProcess:process(clk,rst)
	begin
		if rst ='1' then
			ShiftReg<=(others => '1');
		elsif rising_edge(clk) then	
			if Load='1' then
				ShiftReg <= Din;
			elsif ShiftEn='1' then
				ShiftReg <= '1' & ShiftReg(ShiftReg'left downto 1);
			end if;
		
		end if;
		
	end process;
	Dout<=ShiftReg(0);


end rtl;
		