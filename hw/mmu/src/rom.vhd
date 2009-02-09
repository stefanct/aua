-- Program test/multicycle.asm, generated ROM file

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
		when "1000000000000000" => data <= "0001111111100001";	-- 0x8000: ldih $1, 0xfffe (ldiw $1, 0xfffe)
		when "1000000000000010" => data <= "1100000100000001";	-- 0x8002: lsli $1, 8 (ldiw $1, 0xfffe)
		when "1000000000000100" => data <= "0001111111000001";	-- 0x8004: ldil $1, 0xfffe (ldiw $1, 0xfffe)
		when "1000000000000110" => data <= "0000000001000010";	-- 0x8006: ldi $2, 2
		when "1000000000001000" => data <= "1111100000100010";	-- 0x8008: st $2, $1
		when "1000000000001010" => data <= "0001111111100001";	-- 0x800a: ldih $1, 0xffff (ldiw $1, 0xffff)
		when "1000000000001100" => data <= "1100000100000001";	-- 0x800c: lsli $1, 8 (ldiw $1, 0xffff)
		when "1000000000001110" => data <= "0001111111100001";	-- 0x800e: ldil $1, 0xffff (ldiw $1, 0xffff)
		when "1000000000010000" => data <= "0001010101000010";	-- 0x8010: ldi $2, 0xaa
		when "1000000000010010" => data <= "1111100000100010";	-- 0x8012: st $2, $1
		when "1000000000010100" => data <= "0000000000000000";	-- 0x8014: ldi $0, 0 (nop)
		when "1000000000010110" => data <= "0000000000000000";	-- 0x8016: ldi $0, 0 (nop)
		when "1000000000011000" => data <= "0000000000000000";	-- 0x8018: ldi $0, 0 (nop)
		when "1000000000011010" => data <= "0000000000000000";	-- 0x801a: ldi $0, 0 (nop)
		when "1000000000011100" => data <= "1111000000100101";	-- 0x801c: ld $5, $1
		when "1000000000011110" => data <= "0001111111101010";	-- 0x801e: ldih $10, SC_DIGITS (ldiw $10, SC_DIGITS)
		when "1000000000100000" => data <= "1100000100001010";	-- 0x8020: lsli $10, 8 (ldiw $10, SC_DIGITS)
		when "1000000000100010" => data <= "0000001000001010";	-- 0x8022: ldil $10, SC_DIGITS (ldiw $10, SC_DIGITS)
		when "1000000000100100" => data <= "1111100101000101";	-- 0x8024: st $5, $10
		when "1000000000100110" => data <= "0100000000000000";	-- 0x8026: brezi $0, loop (rjmpi loop)
		when "1000000001010000" => data <= "0000000001000000";
		when "1000000001010010" => data <= "0000000001111001";
		when "1000000001010100" => data <= "0000000000100100";
		when "1000000001010110" => data <= "0000000000110000";
		when "1000000001011000" => data <= "0000000000011001";
		when "1000000001011010" => data <= "0000000000010010";
		when "1000000001011100" => data <= "0000000000000010";
		when "1000000001011110" => data <= "0000000001111000";
		when "1000000001100000" => data <= "0000000000000000";
		when "1000000001100010" => data <= "0000000000010000";
		when others => data <= "0000000000000000";
	end case;
end process;

end rtl;
