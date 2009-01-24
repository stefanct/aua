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
				opa			: out word_t;
				opb			: out word_t;

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
			mmu_result	: in word_t;
			mmu_wr_data		: out word_t;
			mmu_enable		: out std_logic;
			mmu_opcode	: out std_logic_vector(1 downto 0);
			mmu_valid		: in std_logic;
			
			-- pipeline interlock
			ex_locks	: out std_ulogic
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

		-- IF/ID
		signal ifid_opcode	: opcode_t;
		signal ifid_dest	: reg_t;
		signal ifid_pc		: word_t;
		signal ifid_rega	: reg_t;
		signal ifid_regb	: reg_t;
		signal ifid_async_rega	: reg_t;
		signal ifid_async_regb	: reg_t;
		signal ifid_imm		: std_logic_vector(7 downto 0);
		-- ID/IF
		signal idif_pc		: word_t;
		signal idif_branch	: std_logic;
		-- IF/MMU
		signal ifmmu_addr	: word_t;
		signal ifmmu_data	: word_t;
		signal ifmmu_valid	: std_logic;
		-- ID/EX and EX/ID (for WB)
		signal idex_opcode	: opcode_t;
		signal idex_dest	: reg_t;
		signal idex_opa		: word_t;
		signal idex_opb		: word_t;
		signal exid_dest	: reg_t;
		signal exid_result	: word_t;
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
    cmp_mmu: mmu
    	generic map(irq_cnt)
    	port map(clk, reset, ifmmu_addr, ifmmu_data, ifmmu_valid, exmmu_address, exmmu_result_mmu, exmmu_wr_data, exmmu_enable, exmmu_mmu_opcode, exmmu_valid,
    	 	mmuio_address, mmuio_wr_data, mmuio_rd, mmuio_wr, mmuio_rd_data, mmuio_rdy_cnt,
    	 	sram_addr, sram_dq, sram_we, sram_oe, sram_ub, sram_lb, sram_ce);
    	  	--mmu_sram_addr, mmu_sram_dq, mmu_sram_we, mmu_sram_oe, mmu_sram_ub, mmu_sram_lb, mmu_sram_ce);
    cmp_if: ent_if
    	port map(clk, reset, ifid_opcode, ifid_dest, ifid_pc, ifid_rega, ifid_regb, ifid_imm, ifid_async_rega, ifid_async_regb, idif_pc, idif_branch, ifmmu_addr, ifmmu_data);
    cmp_id: id
    	port map(clk, reset, ifid_opcode, ifid_dest, ifid_pc, ifid_rega, ifid_regb, ifid_imm, ifid_async_rega, ifid_async_regb, exid_dest, exid_result, idex_opcode, idex_dest, idex_opa, idex_opb, idif_pc, idif_branch);
    cmp_ex: ex
    	port map(clk, reset, idex_opcode, idex_dest, idex_opa, idex_opb, exid_dest, exid_result, exmmu_address, exmmu_result_mmu, exmmu_wr_data, exmmu_enable, exmmu_mmu_opcode, exmmu_valid);

	
	--IO devices below
	cmp_switches: switches
    	generic map((others => '0'))
    	port map(clk, reset, mmuio_address, mmuio_wr_data, mmuio_rd, mmuio_wr, mmuio_rd_data, mmuio_rdy_cnt, switch_pins, led_pins);
    end sat1;
