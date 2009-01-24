library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.aua_types.all;

entity instr_cache is
	port (
		clk     : in std_logic;
		reset	: in std_logic;

		-- cache/if
		id_instr_addr	: in word_t;
		id_instr_valid	: out std_logic;
		id_instr		: out word_t;
		-- cache/mmu
		mmu_instr_addr	: out word_t;
		mmu_instr_valid	: in std_logic;
		mmu_instr		: in word_t
	);
end instr_cache;
