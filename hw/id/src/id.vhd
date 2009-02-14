library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.aua_types.all;

entity id is
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
		opb_isfrom_regb	: out boolean;

		-- branch decision
		pc_out		: out pc_t;
		branch_out	: out std_logic;

		-- interlock
		lock		: in std_logic;
		id_locks	: out std_logic
	);
end id;

architecture sat1 of id is
	component reg is
		port (
			clk			: in std_logic;
			reset		: in std_logic;
			async_rega	: in reg_t;
			async_regb	: in reg_t;
			rega		: in reg_t;
			regb		: in reg_t;

			async_regr	: in reg_t;
			async_valr	: in word_t;

			vala		: out word_t;
			valb		: out word_t
		);
	end component;

	signal opcode_nxt	: opcode_t;
	signal dest_nxt		: reg_t;
	signal opa_nxt		: word_t;
	signal opb_nxt		: word_t;
	signal dest			: reg_t;
	signal opa			: word_t;
	signal opb			: word_t;
	signal vala			: word_t;
	signal valb			: word_t;

	signal rega_nxt				: reg_t;
	signal regb_nxt				: reg_t;
	signal opb_isfrom_regb_nxt	: boolean;
	
	signal jmpl_op		: std_logic; -- set if instr is jmpl. used to propagate $ra to EX
	signal opa_to_nop	: std_logic; -- set if we need opa to be all 0s for idle EX

	signal br_data_hz_nxt	: std_logic;
	signal br_data_hz		: std_logic;

begin
	cmp_reg : reg
		port map(clk, reset, async_rega, async_regb, rega_in, regb_in, regr, valr, vala, valb);
		
		dest_out <= dest;
		rega_nxt <= rega_in;
		regb_nxt <= regb_in;
		id_locks <= br_data_hz_nxt;

branch: process (opcode_in, pc_in, vala, dest_in, dest, opb_nxt, rega_in, regb_in, br_data_hz)
		variable inv : std_logic; -- set if op is a "not branch"
		variable brinstr : std_logic; -- set if op changes PC
	begin
		inv := '0';
		brinstr := '0';

		br_data_hz_nxt <= '0';
		opa_to_nop <= '0';
		jmpl_op <= '0';
		pc_out <= resize(unsigned(to_integer(pc_in) + signed(resize(unsigned(opb_nxt(ADDR_SIZE-1 downto 1)&'0'), ADDR_SIZE+1))), ADDR_SIZE);
		--~ pc_out <= unsigned(resize(unsigned(opb_nxt(ADDR_SIZE-1 downto 1)&'0'), ADDR_SIZE+1)); -- numeric_std warnings in modelsim
		opcode_nxt <= opcode_in;

		if opcode_in(5 downto 3)="010" then -- branch imm
			inv := opcode_in(2);
			brinstr := '1';
			-- schedule nop
			opcode_nxt <= (others => '0');
			opa_to_nop <= '1';
			dest_nxt <= (others => '0');
		elsif opcode_in(5 downto 1) ="00111" then
			inv := opcode_in(0);
			brinstr := '1';
			-- schedule nop
			opcode_nxt <= (others => '0');
			opa_to_nop <= '1';
			dest_nxt <= (others => '0');
		elsif opcode_in = "001101" then
			inv := '0';
			brinstr := '1';
			-- jmpl, schedule mov r31, pc!
			opcode_nxt <= "111011";
			dest_nxt <= "11111";
			jmpl_op <= '1';
			-- jump is absolute!
			pc_out <= pc_t(opb_nxt);
		elsif opcode_in(5 downto 2) = "1101" or opcode_in(5 downto 1) = "11100" then
			dest_nxt <= "11011";
		else
			dest_nxt <= dest_in;
		end if;
		
		branch_out <= '0';
		if brinstr='1' then
			if (dest=rega_in or dest=regb_in) and br_data_hz='0' then
				br_data_hz_nxt <= '1';
			elsif (x"0000"=vala xor inv='1') then
				branch_out <= '1';
			end if;
		end if;
	end process;

	-- inserts a nop (for branches etc.)
insert_nop: process (vala, opa_to_nop)
	begin
		if opa_to_nop = '1' then
			opa_nxt <= (others => '0');
		else
			opa_nxt <= vala;
		end if;
	end process;

	-- sign extend, expand and mux with regb
extend_n_mux: process (opcode_in, imm_in, valb, jmpl_op, pc_in)
	begin
		opb_isfrom_regb_nxt <= false;
		if opcode_in(5 downto 3)="000" then
			opb_nxt <= (15 downto 8 => '0') & imm_in(7 downto 0);
		elsif opcode_in(5 downto 2) ="1100" or opcode_in(5 downto 0) ="111010" then
			--expand whole imm (alu has to take care if thats "too much")
			opb_nxt <= (15 downto 7 => '0') & imm_in(6 downto 0);
		elsif opcode_in(5 downto 4)="01" then
			--sign extend imm(6 downto 0)
			if opcode_in(3) = '0' then -- imm branch; word addressing -> shift
				opb_nxt <= (15 downto 8 => imm_in(6)) & imm_in(6 downto 0) & '0';
			else
				opb_nxt <= (15 downto 7 => imm_in(6)) & imm_in(6 downto 0);
			end if;
		elsif jmpl_op='1' then
			opb_nxt <= word_t(pc_in);
		else
			opb_isfrom_regb_nxt <= true;
			opb_nxt <= valb;
		end if;
	end process;	
	
sync: process (clk, reset)
	begin
		if reset = '1' then
			opcode_out <= (others => '0');
			--~ dest_out <= (others => '0');
			dest <= (others => '0');
			opa_out <= (others => '0');
			opb_out <= (others => '0');

			rega_out <= (others => '0');
			regb_out <= (others => '0');
			br_data_hz <= '0';
			opb_isfrom_regb <= false;
		elsif rising_edge(clk) then
			if lock/='1' then
				opcode_out <= opcode_nxt;
				--~ dest_out <= dest_nxt;
				dest <= dest_nxt;
				opa_out <= opa_nxt;
				opb_out <= opb_nxt;
			--~ else
				--~ opcode <= opcode;
				--~ dest <= dest;
				--~ opa <= opa;
				--~ opb <= opb;
				rega_out <= rega_nxt;
				regb_out <= regb_nxt;
				opb_isfrom_regb <= opb_isfrom_regb_nxt;
				br_data_hz <= br_data_hz_nxt;
			end if;
		end if;
	end process;
end sat1;
