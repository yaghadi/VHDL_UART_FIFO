--library decalration
library ieee;
use ieee.std_logic_1164.all;
--entity 
entity ShiftRegister is
	generic(
		DOUT_WIDTH : integer;
		SHIFT_DIR : character -- 'L' generates a shift to the left and 'R' generate a shift to the right
	);
	port(
		clk : in std_logic;
		rst : in std_logic;
		
		ShiftEn :in std_logic;
		Din 	:in std_logic;
		Dout :out std_logic_vector(DOUT_WIDTH-1 downto 0)
	);
end entity;

architecture rtl of ShiftRegister is
Signal ShiftReg : std_logic_vector(DOUT_WIDTH-1 downto 0);
begin
	Dout<=ShiftReg;

	SHIFT_TO_THE_RIGHT : if SHIFT_DIR ='R' generate
	--Shift ShiftReg to the right (when the serial data is transmitted LSB first)
		ShiftR_proc:process(clk,rst)
		begin
			if rst ='1' then 
				ShiftReg <=(others => '0');
			elsif rising_edge(clk) then 
				if ShiftEn ='1' then 
					ShiftReg <= Din & ShiftReg(ShiftReg'left downto 1);
				end if;
			end if;
		end process;
	end generate;
	SHIFT_TO_THE_LEFT : if SHIFT_DIR ='L' generate
	--Shift ShiftReg to the left (when the serial data is transmitted MSB first)
		Shiftl_proc:process(clk,rst)
		begin
			if rst ='1' then 
				ShiftReg <=(others => '0');
			elsif rising_edge(clk) then 
				if ShiftEn ='1' then 
					ShiftReg <=ShiftReg(ShiftReg'left-1 downto 0) & Din ;
				end if;
			end if;
		end process;
	end generate;
	

	
end rtl;