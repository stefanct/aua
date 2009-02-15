library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.aua_types.all;

entity alu is
	port (
		clk		: in	std_logic;
		reset	: in	std_logic;
		opcode	: in	opcode_t;
		opa		: in	word_t;
		opb		: in	word_t;
		result	: out	word_t
	);
end alu;
