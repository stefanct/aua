library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.aua_config.all;
use work.aua_types.all;

entity aua is

port (
	clk			: in std_logic;
	reset_pin	: in std_logic;
	switch_pins	: in std_logic_vector(15 downto 0);
	led_pins	: out std_logic_vector(15 downto 0);
	sram_addr	: out std_logic_vector(17 downto 0);
	sram_dq		: inout word_t;
	sram_we		: out std_logic;
	sram_oe		: out std_logic;
	sram_ub		: out std_logic;
	sram_lb		: out std_logic;
	sram_ce		: out std_logic
);
end aua;

architecture sat1 of aua is
	component ent_if is
		port (
			clk     : in std_logic;
			reset	: in std_logic;

			-- pipeline register outputs
			opcode	: out opcode_t;
			dest	: out reg_t;
			pc_out	: out word_t;
			rega	: out reg_t;
			regb	: out reg_t;
			imm		: out std_logic_vector(7 downto 0);

			-- asynchron register outputs
			async_rega	: out reg_t;
			async_regb	: out reg_t;
				
			-- branches (from ID)
			pc_in		: in word_t;
			branch		: in std_logic;

			-- mmu
			instr_addr	: out word_t;
			instr_valid	: in std_logic;
			instr_data	: in word_t

		);
	end component;

	component id is
		port (
			clk     : in std_logic;
			reset	: in std_logic;

			-- pipeline register inputs
			opcode	: in opcode_t;
			dest	: in reg_t;
			pc		: in word_t;
			rega	: in reg_t;
			regb	: in reg_t;
			imm		: in std_logic_vector(7 downto 0);

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

			-- branch decision
			pc_out		: out word_t;
			branch_out	: out std_logic
		);
	end component;

	component ex is
		port (
		clk     : in std_logic;
		reset	: in std_logic;

		-- pipeline register inputs
		opcode	: in opcode_t;
		dest	: in reg_t;
		opa		: in word_t;
		opb		: in word_t;
		
		-- pipeline register outputs
		dest_out	: out reg_t;
		result		: out word_t;

		-- interface to MMU
		mmu_address		: out word_t;
		mmu_result		: in word_t;
		mmu_wr_data		: out word_t;
		mmu_enable		: out std_logic;
		mmu_opcode		: out std_logic_vector(1 downto 0);
		mmu_valid		: in std_logic;
		
		-- pipeline interlock
		ex_locks	: out std_ulogic
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
			irq_cnt	: natural
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
			ex_wr_data	: out word_t;
			ex_rd_data	: in word_t;
			ex_enable	: in std_logic;
			ex_opcode	: in std_logic_vector(1 downto 0);
			ex_valid	: out std_logic;

			-- SimpCon interface to IO devices
			io_address	: out std_logic_vector(31 downto 0);
			io_wr_data	: out std_logic_vector(31 downto 0);
			io_rd		: out std_logic;
			io_wr		: out std_logic;
			io_rd_data	: in std_logic_vector(31 downto 0);
			io_rdy_cnt	: in unsigned(1 downto 0);
			
			-- interface to SRAM
			sram_addr	: out std_logic_vector(17 downto 0);
			sram_dq		: inout word_t;
			sram_we		: out std_logic; -- write enable, low active, 0=enable, 1=disable
			sram_oe		: out std_logic; -- output enable, low active
			sram_ub		: out std_logic; -- upper byte, low active
			sram_lb		: out std_logic; -- lower byte, low active
			sram_ce		: out std_logic -- chip enable, low active
		);
	end component;

	component switches is
		generic(
			sc_addr	: std_logic_vector(31 downto 0)
		);
		port (
			clk     : in std_logic;
			reset	: in std_logic;

			-- SimpCon slave interface to IO ctrl
			address	: in std_logic_vector(31 downto 0);
			wr_data	: in std_logic_vector(31 downto 0);
			rd		: in std_logic;
			wr		: in std_logic;
			rd_data	: out std_logic_vector(31 downto 0);
			rdy_cnt	: out unsigned(1 downto 0);

			-- pins
			switch_pins	: in std_logic_vector(15 downto 0);
			led_pins	: out std_logic_vector(15 downto 0)
		);
	end component;

	signal reset	: std_logic;

	-- pipeline registers (read by top)
	-- IF/ID
	signal ifid_opcode_out		: opcode_t;
	signal ifid_dest_out			: reg_t;
	signal ifid_pc_out			: word_t;
	signal ifid_rega_out			: reg_t;
	signal ifid_regb_out			: reg_t;
	signal ifid_async_rega_out	: reg_t;
	signal ifid_async_regb_out	: reg_t;
	signal ifid_imm_out			: std_logic_vector(7 downto 0);
	-- ID/IF
	signal idif_pc_out		: word_t;
	signal idif_branch_out	: std_logic;
	-- ID/EX
	signal idex_opcode_out	: opcode_t;
	signal idex_dest_out		: reg_t;
	signal idex_opa_out		: word_t;
	signal idex_opb_out		: word_t;
	-- EX/ID (for WB)
	signal exid_dest_out		: reg_t;
	signal exid_result_out	: word_t;

	-- pipeline registers (written by top)
	-- IF/ID
	signal ifid_opcode_in		: opcode_t;
	signal ifid_dest_in		: reg_t;
	signal ifid_pc_in			: word_t;
	signal ifid_rega_in		: reg_t;
	signal ifid_regb_in		: reg_t;
	signal ifid_async_rega_in	: reg_t;
	signal ifid_async_regb_in	: reg_t;
	signal ifid_imm_in			: std_logic_vector(7 downto 0);
	-- ID/IF
	signal idif_pc_in		: word_t;
	signal idif_branch_in	: std_logic;
	-- ID/EX
	signal idex_opcode_in	: opcode_t;
	signal idex_dest_in	: reg_t;
	signal idex_opa_in		: word_t;
	signal idex_opb_in		: word_t;
	-- EX/ID (for WB)
	signal exid_dest_in	: reg_t;
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
	signal mmuio_address	: std_logic_vector(31 downto 0);
	signal mmuio_wr_data	: std_logic_vector(31 downto 0);
	signal mmuio_rd			: std_logic;
	signal mmuio_wr			: std_logic;
	signal mmuio_rd_data	: std_logic_vector(31 downto 0);
	signal mmuio_rdy_cnt	: unsigned(1 downto 0);
	-- MMU/SRAM
	signal mmu_sram_addr	: std_logic_vector(17 downto 0);
	signal mmu_sram_dq		: word_t;
	signal mmu_sram_we		: std_logic;
	signal mmu_sram_oe		: std_logic;
	signal mmu_sram_ub		: std_logic;
	signal mmu_sram_lb		: std_logic;
	signal mmu_sram_ce		: std_logic;

	--interlocks
	signal ex_locks	: std_logic;


begin
reset <= reset_pin; -- in case we need to invert... should be "calculated" with help of a constant from config
cmp_if: ent_if
	port map(clk, reset, ifid_opcode_in, ifid_dest_in, ifid_pc_in, ifid_rega_in, ifid_regb_in, ifid_imm_in, ifid_async_rega_in, ifid_async_regb_in, idif_pc_out, idif_branch_out, ifcache_addr, ifcache_valid, ifcache_data);
cmp_id: id
	port map(clk, reset, ifid_opcode_out, ifid_dest_out, ifid_pc_out, ifid_rega_out, ifid_regb_out, ifid_imm_out, ifid_async_rega_out, ifid_async_regb_out, exid_dest_out, exid_result_out, idex_opcode_in, idex_dest_in, idex_opa_in, idex_opb_in, idif_pc_in, idif_branch_in);
cmp_ex: ex
	port map(clk, reset, idex_opcode_out, idex_dest_out, idex_opa_out, idex_opb_out, exid_dest_in, exid_result_in, exmmu_address, exmmu_result_mmu, exmmu_wr_data, exmmu_enable, exmmu_mmu_opcode, exmmu_valid, ex_locks);
cmp_icache: instr_cache
	port map(clk, reset, ifcache_addr, ifcache_valid, ifcache_data, cachemmu_addr, cachemmu_valid, cachemmu_data);
cmp_mmu: mmu
	generic map(irq_cnt)
	port map(clk, reset, cachemmu_addr, cachemmu_data, cachemmu_valid, exmmu_address, exmmu_result_mmu, exmmu_wr_data, exmmu_enable, exmmu_mmu_opcode, exmmu_valid,
		mmuio_address, mmuio_wr_data, mmuio_rd, mmuio_wr, mmuio_rd_data, mmuio_rdy_cnt,
		sram_addr, sram_dq, sram_we, sram_oe, sram_ub, sram_lb, sram_ce);
		--mmu_sram_addr, mmu_sram_dq, mmu_sram_we, mmu_sram_oe, mmu_sram_ub, mmu_sram_lb, mmu_sram_ce);
	
sync: process(clk, reset)
	begin
		if reset = '1' then
			ifid_opcode_out <= (others => '0');
			ifid_dest_out <= (others => '0');
			ifid_pc_out <= (others => '0');
			ifid_rega_out <= (others => '0');
			ifid_regb_out <= (others => '0');
			ifid_async_rega_out <= (others => '0');
			ifid_async_regb_out <= (others => '0');
			ifid_imm_out <= (others => '0');
			idif_pc_out <= (others => '0');
			idif_branch_out <= '0';
			idex_opcode_out <= (others => '0');
			idex_dest_out <= (others => '0');
			idex_opa_out <= (others => '0');
			idex_opb_out <= (others => '0');
			exid_dest_out <= (others => '0');
			exid_result_out <= (others => '0');
		elsif rising_edge(clk) then
			if ex_locks = '1' then
				ifid_opcode_out <= ifid_opcode_out;
				ifid_dest_out <= ifid_dest_out;
				ifid_pc_out <= ifid_pc_out;
				ifid_rega_out <= ifid_rega_out;
				ifid_regb_out <= ifid_regb_out;
				ifid_async_rega_out <= ifid_async_rega_out;
				ifid_async_regb_out <= ifid_async_regb_out;
				ifid_imm_out <= ifid_imm_out;
				idif_pc_out <= idif_pc_out;
				idif_branch_out <= idif_branch_out;
				idex_opcode_out <= idex_opcode_out;
				idex_dest_out <= idex_dest_out;
				idex_opa_out <= idex_opa_out;
				idex_opb_out <= idex_opb_out;
				exid_dest_out <= exid_dest_out;
				exid_result_out <= exid_result_out;
			else
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
				idex_opa_out <= idex_opa_in;
				idex_opb_out <= idex_opb_in;
				exid_dest_out <= exid_dest_in;
				exid_result_out <= exid_result_in;
			end if;
		end if;
	end process;

--IO devices below
cmp_switches: switches
	generic map((others => '0'))
	port map(clk, reset, mmuio_address, mmuio_wr_data, mmuio_rd, mmuio_wr, mmuio_rd_data, mmuio_rdy_cnt, switch_pins, led_pins);
end sat1;
