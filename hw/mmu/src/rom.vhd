-- Program bla, generated ROM file

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
		when "1000000000000000" => data <= "0000001011100000";	-- ldi $0 23
		when "1000000000000010" => data <= "1110110000000001";	-- mov $1 $0
		when "1000000000000100" => data <= "1110110000000011";	-- mov $3 $0
		when "1000000000000110" => data <= "1110110000000010";	-- mov $2 $0
		when "1000000000001000" => data <= "0000000000000000";	-- ldi $0 0
		when "1000000000001010" => data <= "0000000000000000";	-- ldi $0 0
		when "1000000000001100" => data <= "0000000000000000";	-- ldi $0 0
		when "1000000000001110" => data <= "0000001011100001";	-- ldi $1 23
		when "1000000000010000" => data <= "1110110000100001";	-- mov $1 $1
		when "1000000000010010" => data <= "1110110000100011";	-- mov $3 $1
		when "1000000000010100" => data <= "1110110000100010";	-- mov $2 $1
		when "1000000000010110" => data <= "0110000001100001";	-- addi $1 3
		when "1000000000011000" => data <= "0110000001100001";	-- addi $1 3
		when "1000000000011010" => data <= "0110000001100001";	-- addi $1 3
		when "1000000000011100" => data <= "0110000001100001";	-- addi $1 3
		when "1000000000011110" => data <= "0110000001100001";	-- addi $1 3
		when "1000000000100000" => data <= "0100111011000000";	-- brezi $0 loop
		when others => data <= "0000000000000000";
	end case;
end process;

end rtl;
