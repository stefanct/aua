library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.aua_types.all;

entity sc_de2_switches is
	port (
		clk     : in std_logic;
		reset	: in std_logic;

		-- SimpCon slave interface to IO ctrl
		address	: in sc_addr_t;
		wr_data	: in sc_data_t;
		rd		: in std_logic;
		wr		: in std_logic;
		rd_data	: out sc_data_t;
		rdy_cnt	: out sc_rdy_cnt_t;

		-- pins
		switch_pins	: in std_logic_vector(15 downto 0);
		led_pins	: out std_logic_vector(15 downto 0)
	);
end sc_de2_switches;

architecture sat1 of sc_de2_switches is
	signal switch_reg	: std_logic_vector(15 downto 0);
	signal led_reg	: std_logic_vector(15 downto 0);
begin
	rdy_cnt <= (others => '0');	-- no wait states
	rd_data <= ((rd_data'length-1 downto switch_reg'length => '0')&switch_reg);

	led_pins <= led_reg;

	process(clk, reset)
	begin

		if (reset='1') then
			switch_reg <= (others => '0');
			led_reg <= (others => '0'); -- high active LEDs

		elsif rising_edge(clk) then
			if rd = '1' then
				switch_reg <= switch_pins;
			end if;

			if wr = '1' then
				led_reg <= not wr_data(15 downto 0);
			end if;
		end if;

	end process;

end sat1;
