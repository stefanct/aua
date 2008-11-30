    library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

    entity wb is
		port (
			reset	: in std_logic;
			opcode	: in std_logic_vector(5 downto 0);
			dest	: in std_logic_vector(4 downto 0);
			result	: in std_logic_vector(15 downto 0);

			dest_out	: out std_logic_vector(4 downto 0);
			result_out	: out std_logic_vector(15 downto 0)
		);
    end wb;

    architecture sat1 of wb is

--        constant CLK_FREQ : integer := 50000000; -- 20M for cycore; 50M for de2
--		type state_type		is (st_init, st_wait, st_rdst, st_rdcmd, st_flood_adr, st_flood);
--		signal state 		: state_type;
--		signal sc_adr	: std_logic_vector(0 downto 0);
    begin

	dest_out <= (others => '0');
	result_out <= (others => '0');

    end sat1;