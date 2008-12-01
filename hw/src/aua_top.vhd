    library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

    entity aua is

    port (
		clk			: in std_logic;
		reset_pin	: in std_logic
    );
    end aua;

    architecture sat1 of aua is
		component ent_if is
			port (
				clk     : in std_logic;
				reset	: in std_logic;

				-- pipeline register outputs
				opcode	: out std_logic_vector(5 downto 0);
				dest	: out std_logic_vector(4 downto 0);
				pc_out	: out std_logic_vector(15 downto 0);
				rega	: out std_logic_vector(4 downto 0);
				regb	: out std_logic_vector(4 downto 0);
				imm		: out std_logic_vector(7 downto 0);

				-- branches (from ID)
				pc_in		: in std_logic_vector(15 downto 0);
				branch		: in std_logic;

				-- mmu
				instr_addr	: out std_logic_vector(15 downto 0);
				instr_data	: in std_logic_vector(15 downto 0)

			);
		end component;

		component id is
			port (
				clk     : in std_logic;
				reset	: in std_logic;

				-- pipeline register inputs
				opcode	: in std_logic_vector(5 downto 0);
				dest	: in std_logic_vector(4 downto 0);
				pc		: in std_logic_vector(15 downto 0);
				rega	: in std_logic_vector(4 downto 0);
				regb	: in std_logic_vector(4 downto 0);
				imm		: in std_logic_vector(7 downto 0);

				-- results from wb to reg file
				regr	: in std_logic_vector(4 downto 0);
				valr	: in std_logic_vector(15 downto 0);

				-- pipeline register outputs
				opcode_out	: out std_logic_vector(5 downto 0);
				dest_out	: out std_logic_vector(4 downto 0);
				opa			: out std_logic_vector(15 downto 0);
				opb			: out std_logic_vector(15 downto 0);

				-- branch decision
				pc_out		: out std_logic_vector(15 downto 0);
				branch_out	: out std_logic
			);
		end component;

		component ex is
			port (
				clk     : in std_logic;
				reset	: in std_logic;

				-- pipeline register inputs
				opcode	: in std_logic_vector(5 downto 0);
				dest	: in std_logic_vector(4 downto 0);
				opa		: in std_logic_vector(15 downto 0);
				opb		: in std_logic_vector(15 downto 0);
				
				-- pipeline register outputs
				opcode_out	: out std_logic_vector(5 downto 0);
				dest_out	: out std_logic_vector(4 downto 0);
				result		: out std_logic_vector(15 downto 0);

				-- SimpCon interface to MMU
				address		: out std_logic_vector(15 downto 0);
				wr_data		: out std_logic_vector(31 downto 0);
				rd			: out std_logic;
				wr			: out std_logic;
				rd_data		: in std_logic_vector(31 downto 0);
				rdy_cnt		: in unsigned(1 downto 0)
			);
		end component;

		component wb is
			port (
				reset	: in std_logic;
				opcode	: in std_logic_vector(5 downto 0);
				dest	: in std_logic_vector(4 downto 0);
				result	: in std_logic_vector(15 downto 0);

				dest_out	: out std_logic_vector(4 downto 0);
				result_out	: out std_logic_vector(15 downto 0)
			);
		end component;

		component mmu is
			port (
				clk     : in std_logic;
				reset	: in std_logic;

				-- IF stage
				instr_addr	: in std_logic_vector(15 downto 0);
				instr_data	: out std_logic_vector(15 downto 0);

				-- SimpCon slave interface to EX stage
				ex_address	: in std_logic_vector(15 downto 0);
				ex_wr_data	: in std_logic_vector(31 downto 0);
				ex_rd		: in std_logic;
				ex_wr		: in std_logic;
				ex_rd_data	: out std_logic_vector(31 downto 0);
				ex_rdy_cnt	: out unsigned(1 downto 0);

				-- SimpCon interface to IO devices
				io_address	: out std_logic_vector(15 downto 0);
				io_wr_data	: out std_logic_vector(31 downto 0);
				io_rd		: out std_logic;
				io_wr		: out std_logic;
				io_rd_data	: in std_logic_vector(31 downto 0);
				io_rdy_cnt	: in unsigned(1 downto 0)
			);
		end component;

		component switches is
			port (
				clk     : in std_logic;
				reset	: in std_logic;

				-- SimpCon slave interface to IO ctrl
				address	: in std_logic_vector(15 downto 0);
				wr_data	: in std_logic_vector(31 downto 0);
				rd		: in std_logic;
				wr		: in std_logic;
				rd_data	: out std_logic_vector(31 downto 0);
				rdy_cnt	: out unsigned(1 downto 0)
			);
		end component;

		signal reset	: std_logic;

		-- IF/ID
		signal ifid_opcode	: std_logic_vector(5 downto 0);
		signal ifid_dest	: std_logic_vector(4 downto 0);
		signal ifid_pc		: std_logic_vector(15 downto 0);
		signal ifid_rega	: std_logic_vector(4 downto 0);
		signal ifid_regb	: std_logic_vector(4 downto 0);
		signal ifid_imm		: std_logic_vector(7 downto 0);
		-- ID/IF
		signal idif_pc		: std_logic_vector(15 downto 0);
		signal idif_branch	: std_logic;
		-- IF/MMU
		signal ifmmu_addr	: std_logic_vector(15 downto 0);
		signal ifmmu_data	: std_logic_vector(15 downto 0);
		-- ID/EX
		signal idex_opcode	: std_logic_vector(5 downto 0);
		signal idex_dest	: std_logic_vector(4 downto 0);
		signal idex_opa		: std_logic_vector(15 downto 0);
		signal idex_opb		: std_logic_vector(15 downto 0);
		-- EX/WB
		signal exwb_opcode	: std_logic_vector(5 downto 0);
		signal exwb_dest	: std_logic_vector(4 downto 0);
		signal exwb_result	: std_logic_vector(15 downto 0);
		-- WB/ID
		signal wbid_dest	: std_logic_vector(4 downto 0);
		signal wbid_result	: std_logic_vector(15 downto 0);
		-- EX/MMU
		signal exmmu_address	: std_logic_vector(15 downto 0);
		signal exmmu_wr_data	: std_logic_vector(31 downto 0);
		signal exmmu_rd			: std_logic;
		signal exmmu_wr			: std_logic;
		signal exmmu_rd_data	: std_logic_vector(31 downto 0);
		signal exmmu_rdy_cnt	: unsigned(1 downto 0);
		-- MMU/IO
		signal mmuio_address	: std_logic_vector(15 downto 0);
		signal mmuio_wr_data	: std_logic_vector(31 downto 0);
		signal mmuio_rd			: std_logic;
		signal mmuio_wr			: std_logic;
		signal mmuio_rd_data	: std_logic_vector(31 downto 0);
		signal mmuio_rdy_cnt	: unsigned(1 downto 0);

	begin
	reset <= reset_pin; -- in case we need to invert... should be "calculated" with help of a constant from config
    cmp_mmu: mmu
    	port map(clk, reset, ifmmu_addr, ifmmu_data, exmmu_address, exmmu_wr_data, exmmu_rd, exmmu_wr, exmmu_rd_data, exmmu_rdy_cnt, mmuio_address, mmuio_wr_data, mmuio_rd, mmuio_wr, mmuio_rd_data, mmuio_rdy_cnt);
    cmp_if: ent_if
    	port map(clk, reset, ifid_opcode, ifid_dest, ifid_pc, ifid_rega, ifid_regb, ifid_imm, idif_pc, idif_branch, ifmmu_addr, ifmmu_data);
    cmp_id: id
    	port map(clk, reset, ifid_opcode, ifid_dest, ifid_pc, ifid_rega, ifid_regb, ifid_imm, wbid_dest, wbid_result, idex_opcode, idex_dest, idex_opa, idex_opb, idif_pc, idif_branch);
    cmp_ex: ex
    	port map(clk, reset, idex_opcode, idex_dest, idex_opa, idex_opb, exwb_opcode, exwb_dest, exwb_result, exmmu_address, exmmu_wr_data, exmmu_rd, exmmu_wr, exmmu_rd_data, exmmu_rdy_cnt);
    cmp_wb: wb
    	port map(reset, exwb_opcode, exwb_dest, exwb_result, wbid_dest, wbid_result);

	
	--IO devices below
	cmp_switches: switches
    	port map(clk, reset, mmuio_address, mmuio_wr_data, mmuio_rd, mmuio_wr, mmuio_rd_data, mmuio_rdy_cnt);
    end sat1;