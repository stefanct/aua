    library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

	use work.aua_types.all;

	entity reg is
		port (
			reset	: in std_logic;
			rega	: in reg_t;
			regb	: in reg_t;

			regr	: in reg_t;
			valr	: in word_t;

			vala	: out word_t;
			valb	: out word_t
		);
    end reg;

    architecture sat1 of reg is

--        constant CLK_FREQ : integer := 50000000; -- 20M for cycore; 50M for de2
--		type state_type		is (st_init, st_wait, st_rdst, st_rdcmd, st_flood_adr, st_flood);
--		signal state 		: state_type;
--		signal sc_adr	: std_logic_vector(0 downto 0);
    begin
		vala <= (others => '0');
		valb <= (others => '0');

    end sat1;