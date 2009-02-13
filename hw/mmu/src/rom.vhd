-- Program test/loop.0.asm, generated ROM file

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
		when "1000000000000000" => data <= "0000000000000000";	-- 0x8000: ldi $0, 0 (nop)
		when "1000000000000010" => data <= "0100111111100000";	-- 0x8002: brezi $0, loop (rjmpi loop)
		when others => data <= "0000000000000000";
	end case;
end process;

end rtl;
