    library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

    entity reg is
		port (
			reset	: in std_logic;
			rega	: in std_logic_vector(4 downto 0);
			regb	: in std_logic_vector(4 downto 0);

			regr	: in std_logic_vector(4 downto 0);
			valr	: in std_logic_vector(15 downto 0);

			vala	: out std_logic_vector(15 downto 0);
			valb	: out std_logic_vector(15 downto 0)
		);
    end reg;

    architecture sat1 of reg is

--        constant CLK_FREQ : integer := 50000000; -- 20M for cycore; 50M for de2
--		type state_type		is (st_init, st_wait, st_rdst, st_rdcmd, st_flood_adr, st_flood);
--		signal state 		: state_type;
--		signal sc_adr	: std_logic_vector(0 downto 0);
    begin

    end sat1;