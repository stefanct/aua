-- Program test/sram.asm, generated ROM file

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
		when "1000000000000000" => data <= "0001111111100001";	-- 0x8000: ldih $1, SC_DIGITS (ldiw $1, SC_DIGITS)
		when "1000000000000010" => data <= "1100000100000001";	-- 0x8002: lsli $1, 8 (ldiw $1, SC_DIGITS)
		when "1000000000000100" => data <= "0000001000000001";	-- 0x8004: ldil $1, SC_DIGITS (ldiw $1, SC_DIGITS)
		when "1000000000000110" => data <= "0001000000000010";	-- 0x8006: ldih $2, SEGS (ldiw $2, SEGS)
		when "1000000000001000" => data <= "1100000100000010";	-- 0x8008: lsli $2, 8 (ldiw $2, SEGS)
		when "1000000000001010" => data <= "0000110000000010";	-- 0x800a: ldil $2, SEGS (ldiw $2, SEGS)
		when "1000000000001100" => data <= "0000000000000011";	-- 0x800c: ldih $3, 0 (ldiw $3, 0)
		when "1000000000001110" => data <= "1100000100000011";	-- 0x800e: lsli $3, 8 (ldiw $3, 0)
		when "1000000000010000" => data <= "0000000000000011";	-- 0x8010: ldil $3, 0 (ldiw $3, 0)
		when "1000000000010010" => data <= "0110000011000010";	-- 0x8012: addi $2, 6
		when "1000000000010100" => data <= "1111000001000100";	-- 0x8014: ld $4, $2
		when "1000000000010110" => data <= "1111100001100100";	-- 0x8016: st $4, $3
		when "1000000000011000" => data <= "1111100000100100";	-- 0x8018: st $4, $1
		when "1000000000011010" => data <= "0000000000000000";	-- 0x801a: ldi $0, 0 (nop)
		when "1000000000011100" => data <= "0000000000000000";	-- 0x801c: ldi $0, 0 (nop)
		when "1000000000011110" => data <= "0000000000000000";	-- 0x801e: ldi $0, 0 (nop)
		when "1000000000100000" => data <= "0000000000000000";	-- 0x8020: ldi $0, 0 (nop)
		when "1000000000100010" => data <= "0110000000100001";	-- 0x8022: addi $1, 1
		when "1000000000100100" => data <= "1111000001100101";	-- 0x8024: ld $5, $3
		when "1000000000100110" => data <= "0000000000000000";	-- 0x8026: ldi $0, 0 (nop)
		when "1000000000101000" => data <= "0000000000000000";	-- 0x8028: ldi $0, 0 (nop)
		when "1000000000101010" => data <= "0000000000000000";	-- 0x802a: ldi $0, 0 (nop)
		when "1000000000101100" => data <= "1111100000100101";	-- 0x802c: st $5, $1
		when "1000000000101110" => data <= "0100000000000000";	-- 0x802e: brezi $0, loop (rjmpi loop)
		when "1000000001100000" => data <= "0000000001000000";
		when "1000000001100010" => data <= "0000000001111001";
		when "1000000001100100" => data <= "0000000000100100";
		when "1000000001100110" => data <= "0000000000110000";
		when "1000000001101000" => data <= "0000000000011001";
		when "1000000001101010" => data <= "0000000000010010";
		when "1000000001101100" => data <= "0000000000000010";
		when "1000000001101110" => data <= "0000000001111000";
		when "1000000001110000" => data <= "0000000000000000";
		when "1000000001110010" => data <= "0000000000010000";
		when others => data <= "0000000000000000";
	end case;
end process;

end rtl;
