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
--	process(reset)
--	begin
--		if reset = '1' then
--			id_instr_valid <= '0';
--			id_instr <= (others => '0');
--			mmu_instr_addr <= (others => '0');
--		elsif rising_edge(clk) then
--		end if;
--	end process;
end cache_null;
