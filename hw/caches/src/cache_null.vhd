library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.aua_types.all;

architecture cache_null of instr_cache is
begin
	mmu_enable <= '1';
	id_instr_valid <= mmu_instr_valid;
	id_instr <= mmu_instr;
	mmu_instr_addr <= id_instr_addr;
end cache_null;
