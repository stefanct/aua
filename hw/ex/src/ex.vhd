library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.aua_types.all;

entity ex is
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
		mmu_address		: out word_t;
		mmu_result		: in word_t;
		mmu_st_data		: out word_t;
		mmu_enable		: out std_logic;
		mmu_opcode		: out std_logic_vector(1 downto 0);
		mmu_done		: in std_logic;
		
		-- pipeline interlock
		ex_locks		: out std_ulogic;
		ex_locks_async	: out std_ulogic
	);
end ex;

architecture sat1 of ex is
	component alu is
		port (
			clk     : in std_logic;
			reset	: in std_logic;
			opcode	: in opcode_t;
			opa		: in word_t;
			opb		: in word_t;
			result	: out word_t
		);
	end component;

	signal dest_nxt		: reg_t;
	signal alu_result	: word_t;
	signal ex_locks_nxt	: std_logic;
begin
	
	dest_out <= dest_nxt;
	ex_locks_async <= ex_locks_nxt;

	cmp_alu: alu
		port map(clk, reset, opcode, opa, opb, alu_result);

ldst_n_mux: process(opcode, opa, opb, dest_in, dest_nxt, mmu_result, mmu_done, alu_result)
	begin
		mmu_address <= opb;
		mmu_st_data <= opa;
		mmu_opcode <= opcode(1 downto 0);
		dest_nxt <= dest_in;

		if opcode(5 downto 2) = "1111" then
			mmu_enable <= '1';
			ex_locks_nxt <= not mmu_done;
			result_out <= mmu_result;
			-- stores and incomplete mmu ops should not alter registers
			if opcode(1) = '1' or mmu_done /= '1' then
				dest_nxt <= (others => '0');
			end if;
		else
			mmu_enable <= '0';
			ex_locks_nxt <= '0';
			result_out <= alu_result;
		end if;

		-- hide r0 changes
		if dest_nxt="00000" then
			result_out <= (others => '0');
		end if;
	end process;
	
sync: process (clk, reset)
	begin
		if reset = '1' then
			ex_locks <= '0';
		elsif rising_edge(clk) then
			ex_locks <= ex_locks_nxt;
		end if;
	end process;
end sat1;
