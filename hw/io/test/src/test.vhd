library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.aua_types.all;

entity sc_test_slave is
	generic(
		sc_addr	: sc_addr_t
	);
	port (
			clk     : in std_logic;
			reset	: in std_logic;

			-- SimpCon slave interface to IO ctrl
			address	: in sc_addr_t;
			wr_data	: in sc_data_t;
			rd		: in std_logic;
			wr		: in std_logic;
			rd_data	: out sc_data_t;
			rdy_cnt	: out sc_rdy_cnt_t
	);
end sc_test_slave;

architecture rtl of sc_test_slave is

	--~ signal xyz	: sc_data_t;

begin

	rdy_cnt <= "00";	-- no wait states
	--~ rd_data <= xyz;

process(clk, reset)
begin
	if (reset='1') then
		rd_data <= (others => '0');
	elsif rising_edge(clk) then
		if address = sc_addr then
			if wr='1' then
				rd_data <= wr_data;
			end if;
		end if;
	end if;
end process;

end rtl;
