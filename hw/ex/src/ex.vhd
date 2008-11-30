    library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

    entity ex is
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
    end ex;

    architecture sat1 of ex is
		component alu is
			port (
				clk     : in std_logic;
				reset	: in std_logic;
				opcode	: in std_logic_vector(5 downto 0);
				opa		: in std_logic_vector(15 downto 0);
				opb		: in std_logic_vector(15 downto 0);
				result	: out std_logic_vector(15 downto 0)
			);
		end component;

		signal opcode_nxt	: std_logic_vector(5 downto 0);
		signal dest_nxt		: std_logic_vector(4 downto 0);
		signal result_nxt	: std_logic_vector(15 downto 0);

		signal result_alu	: std_logic_vector(15 downto 0);

	begin
		cmp_alu: alu
    	port map(clk, reset, opcode, opa, opb, result_alu);

		opcode_nxt <= (others => '0');
		dest_nxt <= (others => '0');
		result_nxt <= result_alu;
		
		address <= (others => '0');
		wr_data <= (others => '0');
		rd <= '0';
		wr <= '0';

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