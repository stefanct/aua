    library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

    entity switches is
		generic(
			sc_addr	: std_logic_vector(31 downto 0)
		);
		port (
			clk     : in std_logic;
			reset	: in std_logic;

			-- SimpCon slave interface to IO ctrl
			address	: in std_logic_vector(31 downto 0);
			wr_data	: in std_logic_vector(31 downto 0);
			rd		: in std_logic;
			wr		: in std_logic;
			rd_data	: out std_logic_vector(31 downto 0);
			rdy_cnt	: out unsigned(1 downto 0);

			-- pins
			switch_pins	: in std_logic_vector(15 downto 0);
			led_pins	: out std_logic_vector(15 downto 0)
		);
    end switches;

    architecture sat1 of switches is
    begin

		rd_data(31 downto 16) <= (others => 'Z');

		process(clk, reset)
		begin

			if (reset='1') then
				rd_data(15 downto 0) <= (others => 'Z');
				led_pins(15 downto 0) <= (others => '1');

			elsif rising_edge(clk) then
				if rd = '1' and address = sc_addr then
						rd_data(15 downto 0) <= switch_pins;
						rdy_cnt <= "00";	-- no wait states
				end if;

				if wr = '1' and address = sc_addr then
						led_pins <= not wr_data(15 downto 0);
						rdy_cnt <= "00";	-- no wait states
				end if;
			end if;

		end process;

	end sat1;