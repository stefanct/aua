library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.aua_types.all;

entity aua is
port (
	clk_in		: in std_logic;
	reset_pin	: in std_logic;
	switch_pins	: in std_logic_vector(15 downto 0);
	led_pins	: out std_logic_vector(15 downto 0);
	digit0_pins	: out std_logic_vector(6 downto 0);
	digit1_pins	: out std_logic_vector(6 downto 0);
	digit2_pins	: out std_logic_vector(6 downto 0);
	digit3_pins	: out std_logic_vector(6 downto 0);
	digit4_pins	: out std_logic_vector(6 downto 0);
	digit5_pins	: out std_logic_vector(6 downto 0);
	sram_addr	: out std_logic_vector(RAM_ADDR_SIZE-1  downto 0);
	sram_dq		: inout word_t;
	sram_we		: out std_logic;
--	sram_oe		: out std_logic;
--	sram_ub		: out std_logic;
--	sram_lb		: out std_logic;
--	sram_ce		: out std_logic
	txd			: out std_logic;
	rxd			: in std_logic
	--~ ncts		: in std_logic;
	--~ nrts		: out std_logic
);
end aua;

architecture sat1 of aua is
    
    component aua_pll is
        port(
         	areset	: in std_logic;
         	inclk0	: in std_logic;
         	c0	: out std_logic
        );
    end component;
    
	component ent_if is
		port (
			clk     : in std_logic;
			reset	: in std_logic;

			-- pipeline register outputs
			opcode_out	: out opcode_t;
			dest_out	: out reg_t;
			pc_out		: out pc_t;
			rega_out	: out reg_t;
			regb_out	: out reg_t;
			imm_out		: out std_logic_vector(7 downto 0);

			-- asynchron register outputs
			async_rega	: out reg_t;
			async_regb	: out reg_t;
				
			-- branches (from ID)
			pc_in		: in pc_t;
			branch		: in std_logic;

			-- cache
			instr_addr	: out word_t;
			instr_valid	: in std_logic;
			instr_data	: in word_t;
			
			-- interlock
			lock	: in std_logic
		);
	end component;

	component id is
		port (
			clk     : in std_logic;
			reset	: in std_logic;

			-- pipeline register inputs
			opcode_in	: in opcode_t;
			dest_in		: in reg_t;
			pc_in		: in pc_t;
			rega_in		: in reg_t;
			regb_in		: in reg_t;
			imm_in		: in std_logic_vector(7 downto 0);

			-- asynchron register inputs
			async_rega	: in reg_t;
			async_regb	: in reg_t;

			-- results from wb to reg file
			regr	: in reg_t;
			valr	: in word_t;

			-- pipeline register outputs
			opcode_out	: out opcode_t;
			dest_out	: out reg_t;
			opa_out		: out word_t;
			opb_out		: out word_t;

			-- needed for EX forwarding
			rega_out	: out reg_t;
			regb_out	: out reg_t;

			-- branch decision
			pc_out		: out pc_t;
			branch_out	: out std_logic;

			-- interlock
			lock		: in std_logic;
			id_locks	: out std_logic
		);
	end component;

	component ex is
		port (
			clk     : in std_logic;
			reset	: in std_logic;

			-- pipeline register inputs
			opcode	: in opcode_t;
			dest_in	: in reg_t;
			opa		: in word_t;
			opb		: in word_t;
			
			-- pipeline register outputs
			dest_out	: out reg_t;
			result_out	: out word_t;

			-- interface to MMU
			mmu_address	: out word_t;
			mmu_result	: in word_t;
			mmu_st_data	: out word_t;
			mmu_enable	: out std_logic;
			mmu_opcode	: out std_logic_vector(1 downto 0);
			mmu_done	: in std_logic;
			
			-- pipeline interlock
			ex_locks		: out std_ulogic;
			ex_locks_async	: out std_ulogic
			);
	end component;

	component instr_cache is
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
	end component;

	component mmu is
		generic (
			CLK_FREQ		: natural;
			SRAM_RD_FREQ	: natural;
			SRAM_WR_FREQ	: natural
		);
		port (
			clk     : in std_logic;
			reset	: in std_logic;

			-- IF stage
			instr_addr	: in word_t;
			instr_data	: out word_t;
			instr_valid	: out std_logic;

			-- interface to EX stage
			ex_address	: in word_t;
			ex_rd_data	: out word_t;
			ex_wr_data	: in word_t;
			ex_enable	: in std_logic;
			ex_opcode	: in std_logic_vector(1 downto 0);
			ex_done		: out std_logic;

			-- SimpCon interface to IO devices
			sc_io_in	: in sc_in_t;
			sc_io_out	: out sc_out_t;
			
			-- interface to SRAM
			sram_addr	: out std_logic_vector(RAM_ADDR_SIZE-1  downto 0);
			sram_dq		: inout word_t;
			sram_we		: out std_logic -- write enable, low active, 0=enable, 1=disable
--			sram_oe		: out std_logic; -- output enable, low active
--			sram_ub		: out std_logic; -- upper byte, low active
--			sram_lb		: out std_logic; -- lower byte, low active
--			sram_ce		: out std_logic -- chip enable, low active
		);
	end component;

	component sc_de2_switches is
		port (
			clk     : in std_logic;
			reset	: in std_logic;

			-- SimpCon slave interface to IO ctrl
			address	: in sc_addr_t;
			wr_data	: in sc_data_t;
			rd		: in std_logic;
			wr		: in std_logic;
			rd_data	: out sc_data_t;
			rdy_cnt	: out sc_rdy_cnt_t;

			-- pins
			switch_pins	: in std_logic_vector(15 downto 0);
			led_pins	: out std_logic_vector(15 downto 0)
		);
	end component;
	
	component sc_de2_digits is
	    port (
			clk     : in std_logic;
			reset	: in std_logic;

			-- SimpCon slave interface to IO ctrl
			address	: in sc_addr_t;
			wr_data	: in sc_data_t;
			rd		: in std_logic;
			wr		: in std_logic;
			rd_data	: out sc_data_t;
			rdy_cnt	: out sc_rdy_cnt_t;

			-- pins
			digit0_pins	: out std_logic_vector(6 downto 0);
			digit1_pins	: out std_logic_vector(6 downto 0);
			digit2_pins	: out std_logic_vector(6 downto 0);
			digit3_pins	: out std_logic_vector(6 downto 0);
			digit4_pins	: out std_logic_vector(6 downto 0);
			digit5_pins	: out std_logic_vector(6 downto 0)
	    );
	end component;

	component sc_uart is
		generic(
			clk_freq	: integer;
			baud_rate	: integer;
			txf_depth	: integer;
			txf_thres	: integer;
			rxf_depth	: integer;
			rxf_thres	: integer
		);
		port (
			clk		: in std_logic;
			reset	: in std_logic;

			-- SimpCon slave interface to IO ctrl
			address	: in sc_addr_t;
			wr_data	: in sc_data_t;
			rd		: in std_logic;
			wr		: in std_logic;
			rd_data	: out sc_data_t;
			rdy_cnt	: out sc_rdy_cnt_t;

			-- pins
			txd		: out std_logic;
			rxd		: in std_logic;
			ncts	: in std_logic;
			nrts	: out std_logic
		);
	end component;

	component sc_test_slave is
		port (
			clk     : in std_logic;
			reset	: in std_logic;

			-- SimpCon slave interface to IO ctrl
			address	: in sc_addr_t;
			wr_data	: in sc_data_t;
			rd		: in std_logic;
			wr		: in std_logic;
			rd_data	: out sc_data_t;
			rdy_cnt	: out sc_rdy_cnt_t
		);
	end component;

	signal reset	: std_logic;

	-- clk Signal aus PLL
	signal clk	: std_logic;
	
	-- pipeline registers (written by top)
	-- IF/ID
	signal ifid_opcode_out		: opcode_t;
	signal ifid_dest_out		: reg_t;
	signal ifid_pc_out			: pc_t;
	signal ifid_rega_out		: reg_t;
	signal ifid_regb_out		: reg_t;
	signal ifid_async_rega_out	: reg_t;
	signal ifid_async_regb_out	: reg_t;
	signal ifid_imm_out			: std_logic_vector(7 downto 0);
	-- ID/IF
	signal idif_pc_out		: pc_t;
	signal idif_branch_out	: std_logic;
	-- ID/EX
	signal idex_opcode_out	: opcode_t;
	signal idex_dest_out	: reg_t;
	signal idex_opa_out		: word_t;
	signal idex_opb_out		: word_t;
	-- EX/ID (for WB)
	signal exid_dest_out	: reg_t;
	signal exid_result_out	: word_t;

	-- pipeline registers (read by top)
	-- IF/ID
	signal ifid_opcode_in		: opcode_t;
	signal ifid_dest_in			: reg_t;
	signal ifid_pc_in			: pc_t;
	signal ifid_rega_in			: reg_t;
	signal ifid_regb_in			: reg_t;
	signal ifid_async_rega_in	: reg_t;
	signal ifid_async_regb_in	: reg_t;
	signal ifid_imm_in			: std_logic_vector(7 downto 0);
	-- ID/IF
	signal idif_pc_in		: pc_t;
	signal idif_branch_in	: std_logic;
	-- ID/EX
	signal idex_opcode_in	: opcode_t;
	signal idex_dest_in		: reg_t;
	signal idex_opa_in		: word_t;
	signal idex_opb_in		: word_t;
	-- EX/ID (for WB)
	signal exid_dest_in		: reg_t;
	signal exid_result_in	: word_t;

	-- IF/CACHE/MMU
	signal ifcache_addr		: word_t;
	signal ifcache_data		: word_t;
	signal ifcache_valid	: std_logic;
	signal cachemmu_addr	: word_t;
	signal cachemmu_data	: word_t;
	signal cachemmu_valid	: std_logic;
              
	-- MMU interfaces
	-- EX/MMU
	signal exmmu_address	: word_t;
	signal exmmu_result_mmu	: word_t;
	signal exmmu_wr_data	: word_t;
	signal exmmu_enable		: std_logic;
	signal exmmu_mmu_opcode	: std_logic_vector(1 downto 0);
	signal exmmu_valid		: std_logic;
	-- MMU/IO
	signal mmuio_out	: sc_out_t;
	signal mmuio_outa	: sc_out_at;
	signal mmuio_in		: sc_in_t;
	signal mmuio_ina	: sc_in_at;	

	--forwarding
	signal id_rega_in	: reg_t;
	signal id_regb_in	: reg_t;
	signal exid_dest	: reg_t;
	signal exid_result	: word_t;
	--interlocks
	signal ex_locks			: std_logic;
	signal ex_locks_async	: std_logic;
	signal lock_if			: std_logic;
	signal lock_id			: std_logic;
	signal id_locks_async	: std_logic;

	-- IO helpers
	signal sc_sel, sc_sel_reg	: integer range 0 to 2**SC_ADDR_BITS; -- one more than needed (for NC)
	signal sc_addr 				: sc_addr_t;

begin
cmp_pll: aua_pll
	port map(reset, clk_in, clk);
cmp_if: ent_if
	port map(clk, reset, ifid_opcode_in, ifid_dest_in, ifid_pc_in, ifid_rega_in, ifid_regb_in, ifid_imm_in, ifid_async_rega_in, ifid_async_regb_in, idif_pc_out, idif_branch_out, ifcache_addr, ifcache_valid, ifcache_data, lock_if);
cmp_id: id
	port map(clk, reset, ifid_opcode_out, ifid_dest_out, ifid_pc_out, ifid_rega_out, ifid_regb_out, ifid_imm_out, ifid_async_rega_out, ifid_async_regb_out, exid_dest_out, exid_result_out, idex_opcode_in, idex_dest_in, idex_opa_in, idex_opb_in, id_rega_in, id_regb_in, idif_pc_in, idif_branch_in, lock_id, id_locks_async);
cmp_ex: ex
	port map(clk, reset, idex_opcode_out, idex_dest_out, idex_opa_out, idex_opb_out, exid_dest_in, exid_result_in, exmmu_address, exmmu_result_mmu, exmmu_wr_data, exmmu_enable, exmmu_mmu_opcode, exmmu_valid, ex_locks, ex_locks_async);
cmp_icache: instr_cache
	port map(clk, reset, ifcache_addr, ifcache_valid, ifcache_data, cachemmu_addr, cachemmu_valid, cachemmu_data);
cmp_mmu: mmu
	generic map(CLK_FREQ, SRAM_RD_FREQ, SRAM_WR_FREQ)
	port map(clk, reset, cachemmu_addr, cachemmu_data, cachemmu_valid,
		exmmu_address, exmmu_result_mmu, exmmu_wr_data, exmmu_enable, exmmu_mmu_opcode, exmmu_valid,
		mmuio_in, mmuio_out,
		sram_addr, sram_dq, sram_we);

	reset <= not reset_pin; -- in case we need to invert... should be "calculated" with help of a constant

	ifid_opcode_out <= ifid_opcode_in;
	ifid_dest_out <= ifid_dest_in;
	ifid_pc_out <= ifid_pc_in;
	ifid_rega_out <= ifid_rega_in;
	ifid_regb_out <= ifid_regb_in;
	ifid_async_rega_out <= ifid_async_rega_in;
	ifid_async_regb_out <= ifid_async_regb_in;
	ifid_imm_out <= ifid_imm_in;
	idif_pc_out <= idif_pc_in;
	idif_branch_out <= idif_branch_in;
	idex_opcode_out <= idex_opcode_in;
	idex_dest_out <= idex_dest_in;
	exid_dest_out <= exid_dest_in;
	exid_result_out <= exid_result_in;
	
	lock_if <= ex_locks_async or id_locks_async;
	lock_id <= ex_locks_async;

ex_fw: process(id_rega_in, id_regb_in, exid_dest, exid_result, idex_opa_in, idex_opb_in, ex_locks)
	begin
		if id_rega_in = exid_dest and ex_locks = '0' then
			idex_opa_out <= exid_result;
		else
			idex_opa_out <= idex_opa_in;
		end if;
		
		if id_regb_in = exid_dest and ex_locks = '0' then
			idex_opb_out <= exid_result;
		else
			idex_opb_out <= idex_opb_in;
		end if;
end process;

sync: process (clk, reset)
	begin
		if reset = '1' then
			exid_dest <= (others => '0');
			exid_result <= (others => '0');
		elsif rising_edge(clk) then
			exid_dest <= exid_dest_in;
			exid_result <= exid_result_in;
		end if;
	end process;

sc_sync: process(clk, reset)
	begin
		if (reset='1') then
			sc_sel_reg <= 0;
		elsif rising_edge(clk) then
			sc_sel_reg <= sc_sel;
		end if;
	end process;

sc_in_mux: process (mmuio_ina, sc_sel_reg)
	begin
		if sc_sel_reg /= SC_SLAVE_CNT then
			mmuio_in.rd_data <= mmuio_ina(sc_sel_reg).rd_data;
			mmuio_in.rdy_cnt <= mmuio_ina(sc_sel_reg).rdy_cnt;
		else
			mmuio_in.rd_data <= (others => '0');
			mmuio_in.rdy_cnt <= (others => '0');
		end if;
	end process;

sc_rdwr_mux: for i in 0 to SC_SLAVE_CNT-1 generate
		mmuio_outa(i).rd <= mmuio_out.rd when i=sc_sel else '0';
		mmuio_outa(i).wr <= mmuio_out.wr when i=sc_sel else '0';
	end generate;

-- 1111* --> Blöcke 0xF000/4
-- 11111111 * --> Blöcke 0xFF00/8 (I/O Devices)
-- 11111111 0000* --> Switches 0xFF00/12
-- 11111111 0001* --> Digits 0xFF10/12
-- 11111111 0002* --> uart 0XFF20/12
-- 
-- 11111111 1111111* --> Test 0xFFFE/15
-- FEDCBA98 76543210
sc_addr <= mmuio_out.address;
sc_sc_selector: process (mmuio_out, sc_addr)
	begin
		if((sc_addr and x"FFF0") = x"FF00") then
			sc_sel <= 0;
		elsif((sc_addr and x"FFF0") = x"FF10") then
			sc_sel <= 1;
		elsif((sc_addr and x"FFF0") = x"FF20") then
			sc_sel <= 2;
		elsif((sc_addr and x"FFFE") = x"FFFE") then
			sc_sel <= 3;
		else
			sc_sel <= SC_SLAVE_CNT;
		end if;
	end process;

--IO devices below
cmp_switches: sc_de2_switches
	port map(clk, reset, mmuio_out.address, mmuio_out.wr_data, mmuio_outa(0).rd, mmuio_outa(0).wr, mmuio_ina(0).rd_data, mmuio_ina(0).rdy_cnt, switch_pins, led_pins);
cmp_digits: sc_de2_digits
	port map(clk, reset, mmuio_out.address, mmuio_out.wr_data, mmuio_outa(1).rd, mmuio_outa(1).wr, mmuio_ina(1).rd_data, mmuio_ina(1).rdy_cnt,
		digit0_pins, digit1_pins, digit2_pins, digit3_pins, digit4_pins, digit5_pins);
cmp_uart: sc_uart
	generic map(CLK_FREQ, UART_RATE, 4, 2, 4, 2)
	port map(clk, reset, mmuio_out.address, mmuio_out.wr_data, mmuio_outa(2).rd, mmuio_outa(2).wr, mmuio_ina(2).rd_data, mmuio_ina(2).rdy_cnt,
		txd, rxd, '0', open);
cmp_test: sc_test_slave
	port map(clk, reset, mmuio_out.address, mmuio_out.wr_data, mmuio_outa(3).rd, mmuio_outa(3).wr, mmuio_ina(3).rd_data, mmuio_ina(3).rdy_cnt);
end sat1;


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
