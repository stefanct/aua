--~ library ieee;
--~ use ieee.std_logic_1164.all;
--~ use work.aua_types.all;
--~ 
--~ package aua_config is
--~ 
--~ --	constants for 50MHz input clock
--~ --	constant clk_freq : integer := 90000000;
--~ --	constant pll_mult : natural := 9;
--~ --	constant pll_div : natural := 5;
--~ 
	--~ constant clk_freq : natural := 50000000;
	--~ constant pll_mult : natural := 1;
	--~ constant pll_div : natural := 1;
--~ 
	--~ constant irq_cnt : natural := 1;
--~ 
--~ 
--~ end aua_config;

--~ package body aua_config is
--~ end aua_config;
--~ 
use WORK.all;

configuration aua_cache of aua is
	for sat1
		for cmp_icache : instr_cache
			use entity work.instr_cache(cache_null);
	    end for;
	    -- does not work... why?
	    --~ for cmp_mmu: mmu
	    	--~ use entity work.mmu(sat1)
	    		--~ generic map(1) -- irq_cnt
	    		--~ port map(clk, reset, cachemmu_addr, cachemmu_data, cachemmu_valid, exmmu_address, exmmu_result_mmu, exmmu_wr_data, exmmu_enable, exmmu_mmu_opcode, exmmu_valid,
					--~ mmuio_address, mmuio_wr_data, mmuio_rd, mmuio_wr, mmuio_rd_data, mmuio_rdy_cnt,
					--~ sram_addr, sram_dq, sram_we, sram_oe, sram_ub, sram_lb, sram_ce);
		--~ end for;

    end for;
end aua_cache;
