library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.aua_types.all;

	--~ port (
		--~ clk     : in std_logic;
		--~ reset	: in std_logic;

		-- cache/if
		--~ id_instr_addr	: in word_t;
		--~ id_instr_valid	: out std_logic;
		--~ id_instr		: out word_t;
		--~ -- cache/mmu
		--~ mmu_instr_addr	: out word_t;
		--~ mmu_instr_valid	: in std_logic;
		--~ mmu_instr		: in word_t

architecture cache_null of instr_cache is
begin
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
