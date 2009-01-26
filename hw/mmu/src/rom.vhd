-- ROM file, generated

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
		when "1000000000000000" => data <= "1100101111100001";	-- scb $1 0x1F
		when "1000000000000010" => data <= "0000000000000000";	-- ldi $0 0
		when "1000000000000100" => data <= "0011010000100000";	-- jmpl $1
		when others => data <= "0000000000000000";
	end case;
end process;

end rtl;
