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

			-- SimpCon interface to MMU
			address		: out word_t;
			wr_data		: out word_t;
			rd			: out std_logic;
			wr			: out std_logic;
			rd_data		: in word_t;
			rdy_cnt		: in unsigned(1 downto 0)
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
		result_nxt <= result_alu;
		
		address <= (others => '0');
		wr_data <= result_nxt;
		rd <= '0';
		wr <= '1';

		process(clk, reset)
		begin
			if reset = '1' then
			elsif rising_edge(clk) then
				opcode_out <= opcode_nxt;
				dest_out <= dest_nxt;
				result <= result_nxt;
			end if;
		end process;

    end sat1;