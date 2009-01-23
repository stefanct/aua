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
			opcode_out	: out opcode_t;
			dest_out	: out reg_t;
			result		: out word_t;

			-- interface to MMU
			address		: out word_t;
			result_mmu	: in word_t;
			wr_data		: out word_t;
			enable		: out std_logic;
			mmu_opcode	: out std_logic_vector(1 downto 0);
			valid		: in std_logic
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

		signal result_alu	: word_t;

	begin
		cmp_alu: alu
    	port map(clk, reset, opcode, opa, opb, result_alu);

		opcode_nxt <= (others => '0');
		dest_nxt <= (others => '0');
	
		address <= opb;
		wr_data <= opa;

		mmu_opcode <= opcode(1 downto 0);

		if opcode(5 downto 2) = "1111" then
			enable <= '1';
			result_nxt <= result_mmu;
		else
			enable <= '0';
			result_nxt <= result_alu;
		end if;

	process(clk, reset)
		begin
			if reset = '1' then
			elsif rising_edge(clk) then
				opcode_out <= opcode_nxt;
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
