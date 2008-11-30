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

    begin
		result <= (others => '0');
    end sat1;