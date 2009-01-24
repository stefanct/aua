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

		signal opcode_nxt	: opcode_t;
		signal dest_nxt		: reg_t;
		signal result_nxt	: word_t;
		signal alu_result	: word_t;

	begin
		cmp_alu: alu
			port map(clk, reset, opcode, opa, opb, alu_result);

		dest_nxt <= (others => '0');
	

	ldst_n_mux: process(opcode, opa, opb, mmu_result, mmu_valid, alu_result)
		begin
			mmu_address <= opb;
			mmu_wr_data <= opa;
			mmu_opcode <= opcode(1 downto 0);

	   		if opcode(5 downto 2) = "1111" then
				mmu_enable <= '1';
				ex_locks <= not mmu_valid;
				result_nxt <= mmu_result;
			else
				mmu_enable <= '0';
				ex_locks <= '0';
				result_nxt <= alu_result;
			end if;
		end process;

	sync: process(clk, reset)
		begin
			if reset = '1' then
			elsif rising_edge(clk) then
				dest_out <= dest_nxt;
				result <= result_nxt;
			end if;
		end process;

--	ldst: process(clk, reset, opcode, opa, opb)
--		begin
--			if reset = '1' then
--			elsif rising_edge(clk) then
--			end if;
--		end process;

		

    end sat1;
