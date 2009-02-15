-- Program test/kurz.asm, generated ROM file

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
		when "1000000000000000" => data <= "0001000000000001";	-- 0x8000: ldih $1, SEGS (ldiw $1, SEGS)
		when "1000000000000010" => data <= "1100000100000001";	-- 0x8002: lsli $1, 8 (ldiw $1, SEGS)
		when "1000000000000100" => data <= "0000101100000001";	-- 0x8004: ldil $1, SEGS (ldiw $1, SEGS)
		when "1000000000000110" => data <= "0001111111101010";	-- 0x8006: ldih $10, SC_DIGITS (ldiw $10, SC_DIGITS)
		when "1000000000001000" => data <= "1100000100001010";	-- 0x8008: lsli $10, 8 (ldiw $10, SC_DIGITS)
		when "1000000000001010" => data <= "0000001000001010";	-- 0x800a: ldil $10, SC_DIGITS (ldiw $10, SC_DIGITS)
		when "1000000000001100" => data <= "0000000000001011";	-- 0x800c: ldih $11, 0xaa (ldiw $11, 0xaa)
		when "1000000000001110" => data <= "1100000100001011";	-- 0x800e: lsli $11, 8 (ldiw $11, 0xaa)
		when "1000000000010000" => data <= "0001010101001011";	-- 0x8010: ldil $11, 0xaa (ldiw $11, 0xaa)
		when "1000000000010010" => data <= "0001000000000011";	-- 0x8012: ldih $3, foo (ldiw $3, foo)
		when "1000000000010100" => data <= "1100000100000011";	-- 0x8014: lsli $3, 8 (ldiw $3, foo)
		when "1000000000010110" => data <= "0000010100000011";	-- 0x8016: ldil $3, foo (ldiw $3, foo)
		when "1000000000011000" => data <= "1111101110111111";	-- 0x8018: st $ra, $sp (call $3)
		when "1000000000011010" => data <= "0110111111011101";	-- 0x801a: addi $sp, -2 (call $3)
		when "1000000000011100" => data <= "0011010001100000";	-- 0x801c: jmpl $3 (call $3)
		when "1000000000011110" => data <= "0110000001011101";	-- 0x801e: addi $sp, 2 (call $3)
		when "1000000000100000" => data <= "1111001110111111";	-- 0x8020: ld $ra, $sp (call $3)
		when "1000000000100010" => data <= "1111100101001011";	-- 0x8022: st $11, $10
		when "1000000000100100" => data <= "0000000000000000";	-- 0x8024: ldi $0, 0 (nop)
		when "1000000000100110" => data <= "0100111111100000";	-- 0x8026: brezi $0, loop (rjmpi loop)
		when "1000000000101000" => data <= "0110000000101011";	-- 0x8028: addi $11, 1
		when "1000000000101010" => data <= "0011101111100000";	-- 0x802a: brez $0, $31 (ret)
		when "1000000001011000" => data <= "0000000001000000";
		when "1000000001011010" => data <= "0000000001111001";
		when "1000000001011100" => data <= "0000000000100100";
		when "1000000001011110" => data <= "0000000000110000";
		when "1000000001100000" => data <= "0000000000011001";
		when "1000000001100010" => data <= "0000000000010010";
		when "1000000001100100" => data <= "0000000000000010";
		when "1000000001100110" => data <= "0000000001111000";
		when "1000000001101000" => data <= "0000000000000000";
		when "1000000001101010" => data <= "0000000000010000";
		when others => data <= "0000000000000000";
	end case;
end process;

end rtl;
