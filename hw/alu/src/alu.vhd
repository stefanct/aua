    library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

    entity alu is

    port (
		clk     : in std_logic;
		reset	: in std_logic;
		opcode	: in std_logic_vector(5 downto 0);
		opa		: in std_logic_vector(15 downto 0);
		opb		: in std_logic_vector(15 downto 0);
		result	: out std_logic_vector(15 downto 0)
    );
    end alu;

    architecture sat1 of alu is

--        constant CLK_FREQ : integer := 50000000; -- 20M for cycore; 50M for de2
--		type state_type		is (st_init, st_wait, st_rdst, st_rdcmd, st_flood_adr, st_flood);
--		signal state 		: state_type;
--		signal sc_adr	: std_logic_vector(0 downto 0);
    begin

    end sat1;