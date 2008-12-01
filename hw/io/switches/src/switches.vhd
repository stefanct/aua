    library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

    entity switches is
		port (
			clk     : in std_logic;
			reset	: in std_logic;

			-- SimpCon slave interface to IO ctrl
			address	: in std_logic_vector(15 downto 0);
			wr_data	: in std_logic_vector(31 downto 0);
			rd		: in std_logic;
			wr		: in std_logic;
			rd_data	: out std_logic_vector(31 downto 0);
			rdy_cnt	: out unsigned(1 downto 0)

		);
    end switches;

    architecture sat1 of switches is
    begin

		rd_data <= (others => 'Z'); -- TODO: das gehoert unbedingt mit einem mux gemacht
		rdy_cnt <= (others => 'Z');

    end sat1;