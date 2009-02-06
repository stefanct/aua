-- Program test/digit.asm, generated ROM file

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
		when "1000000000000000" => data <= "0001111111100001";	-- ldih $1, SC_DIGITS (ldiw $1, SC_DIGITS)
		when "1000000000000010" => data <= "1100000100000001";	-- lsli $1, 8 (ldiw $1, SC_DIGITS)
		when "1000000000000100" => data <= "0000001000000001";	-- ldil $1, SC_DIGITS (ldiw $1, SC_DIGITS)
		when "1000000000000110" => data <= "0001000000000010";	-- ldih $2, SEGS (ldiw $2, SEGS)
		when "1000000000001000" => data <= "1100000100000010";	-- lsli $2, 8 (ldiw $2, SEGS)
		when "1000000000001010" => data <= "0001000010000010";	-- ldil $2, SEGS (ldiw $2, SEGS)
		when "1000000000001100" => data <= "0001111111110100";	-- ldih $20, SC_DIGITS (ldiw $20, SC_DIGITS)
		when "1000000000001110" => data <= "1100000100010100";	-- lsli $20, 8 (ldiw $20, SC_DIGITS)
		when "1000000000010000" => data <= "0000001000010100";	-- ldil $20, SC_DIGITS (ldiw $20, SC_DIGITS)
		when "1000000000010010" => data <= "0110000000110100";	-- addi $20, 1
		when "1000000000010100" => data <= "0000000111110101";	-- ldi $21, 0x0f
		when "1000000000010110" => data <= "1111101010010101";	-- st $21, $20
		when "1000000000011000" => data <= "1110110001000110";	-- mov $6, $2
		when "1000000000011010" => data <= "0000000101000100";	-- ldi $4, 10
		when "1000000000011100" => data <= "0000000000000011";	-- ldi $3, 0
		when "1000000000011110" => data <= "1110110010000101";	-- mov $5, $4
		when "1000000000100000" => data <= "1000100001100101";	-- sub $5, $3
		when "1000000000100010" => data <= "0100111101000101";	-- brezi $5, count_0
		when "1000000000100100" => data <= "0000000000000000";	-- ldi $0, 0 (nop)
		when "1000000000100110" => data <= "0000000000000000";	-- ldi $0, 0 (nop)
		when "1000000000101000" => data <= "1110110001000110";	-- mov $6, $2
		when "1000000000101010" => data <= "1000000001100110";	-- add $6, $3
		when "1000000000101100" => data <= "0000000000000000";	-- ldi $0, 0 (nop)
		when "1000000000101110" => data <= "0000000000000000";	-- ldi $0, 0 (nop)
		when "1000000000110000" => data <= "1111100000110101";	-- st $21, $1
		when "1000000000110010" => data <= "0110000000100011";	-- addi $3, 1
		when "1000000000110100" => data <= "0100110101000000";	-- brezi $0, count (rjmpi count)
		when "1000000000110110" => data <= "0001111111101010";	-- ldih $10, 0xffff (ldiw $10, 0xffff)
		when "1000000000111000" => data <= "1100000100001010";	-- lsli $10, 8 (ldiw $10, 0xffff)
		when "1000000000111010" => data <= "0001111111101010";	-- ldil $10, 0xffff (ldiw $10, 0xffff)
		when "1000000000111100" => data <= "0110111111101010";	-- addi $10, -1
		when "1000000000111110" => data <= "0100111111001010";	-- brezi $10, wait
		when "1000000001000000" => data <= "0100000000000000";	-- brezi $0, loop (rjmpi loop)
		when "1000000010000100" => data <= "0000000010000000";
		when "1000000010000110" => data <= "0000000001111001";
		when "1000000010001000" => data <= "0000000000100100";
		when "1000000010001010" => data <= "0000000000110000";
		when "1000000010001100" => data <= "0000000000011001";
		when "1000000010001110" => data <= "0000000000010010";
		when "1000000010010000" => data <= "0000000000000010";
		when "1000000010010010" => data <= "0000000001111000";
		when "1000000010010100" => data <= "0000000000000000";
		when "1000000010010110" => data <= "0000000000010000";
		when others => data <= "0000000000000000";
	end case;
end process;

end rtl;
