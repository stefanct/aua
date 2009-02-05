-- Program test/iodummy.asm, generated ROM file

library ieee;
use ieee.std_logic_1164.all;

entity rom is
port (
		clk : in std_logic;
		address : in std_logic_vector(15 downto 0);
		q : out std_logic_vector(15 downto 0)
);
end rom;

architecture rtl of rom is

signal data : std_logic_vector(15 downto 0);

begin

q <= data;

process(address) begin

	case address is
		when "1000000000000000" => data <= "0000000000100001";	-- ldi $1, 1
		when "1000000000000010" => data <= "1010110000100001";	-- not $1, $1
		when "1000000000000100" => data <= "0000000111100010";	-- ldi $2, 15
		when "1000000000000110" => data <= "1111110000100010";	-- stb $2, $1
		when "1000000000001000" => data <= "1111010000100011";	-- ldb $3, $1
		when "1000000000001010" => data <= "0100000000000000";	-- brezi $0, loop (rjmpi loop)
		when "1000000000001100" => data <= "0000000000000000";	-- ldi $0, 0 (nop)
		when "1000000000001110" => data <= "0000000000000000";	-- ldi $0, 0 (nop)
		when "1000000000010000" => data <= "0000000000000000";	-- ldi $0, 0 (nop)
		when "1000000000010010" => data <= "1111010000100011";	-- ldb $3, $1
		when "1000000000010100" => data <= "0110000000100011";	-- addi $3, 1
		when "1000000000010110" => data <= "0110000000100011";	-- addi $3, 1
		when others => data <= "0000000000000000";
	end case;
end process;

end rtl;
