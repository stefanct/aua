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
		pc_in		: in word_t;
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
		pc_out		: out word_t;
		branch_out	: out std_logic;

		-- interlock
		lock	: in std_logic
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
	signal rega_nxt		: reg_t;
	signal regb_nxt		: reg_t;
	signal opcode		: opcode_t;
	signal dest			: reg_t;
	signal opa			: word_t;
	signal opb			: word_t;
	signal vala			: word_t;
	signal valb			: word_t;
	
	signal regb_done	: word_t;	-- hides r0 changes
	signal jmpl_op		: std_logic; -- set if instr is jmpl. used to propagate $ra to EX
	signal opa_to_nop	: std_logic; -- set if we need opa to be all 0s for idle EX

begin
	cmp_reg : reg
		port map(clk, reset, async_rega, async_regb, rega_in, regb_in, regr, valr, vala, valb);
		
		rega_nxt <= rega_in;
		regb_nxt <= regb_in;

		--~ opcode_out <= opcode;
		--~ dest_out <= dest;
		--~ opa_out <= opa;
		--~ opb_out <= opb;

branch: process (opcode_in, pc_in, opa_nxt, dest_in, opb_nxt)
		variable inv : std_ulogic;
		variable brinstr : std_ulogic; -- set if op changes PC
	begin
		inv := '0';
		brinstr := '0';

		opa_to_nop <= '0';
		jmpl_op <= '0';
		pc_out <= std_logic_vector(TO_INTEGER(unsigned(pc_in)) + signed(opb_nxt));

		if opcode_in(5 downto 3)="010" then
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
			pc_out <= opb_nxt;
		else
			opcode_nxt <= opcode_in;
			dest_nxt <= dest_in;
		end if;
		
		if ((std_logic_vector(to_unsigned(0, 16)))=opa_nxt xor inv='1') and brinstr='1' then
			branch_out <= '1';
		else
			branch_out <= '0';
		end if;
	end process;

	-- hide r0 changes
r0readonly: process (rega_in, regb_in, vala, valb, opa_to_nop)
	begin
		if rega_in="00000" or opa_to_nop = '1' then
			opa_nxt <= (others => '0');
		else
			opa_nxt <= vala;
		end if;

		if regb_in=(4 downto 0=>'0') then
			regb_done <= (others => '0');
		else
			regb_done <= valb;
		end if;
	end process;

	-- sign extend, expand and mux with regb
extend: process (opcode_in, imm_in,regb_done, jmpl_op, pc_in)
	begin
		if opcode_in(5 downto 3)="000" then
			opb_nxt <= (15 downto 8 => '0') & imm_in(7 downto 0);
		elsif opcode_in(5 downto 2) ="1100" or opcode_in(5 downto 0) ="111010" then
			--expand whole imm (alu has to take care if thats "too much")
			opb_nxt <= (15 downto 7 => '0') & imm_in(6 downto 0);
		elsif opcode_in(5 downto 4)="01" then
			--sign extend imm(6 downto 0)
			opb_nxt <= (15 downto 7 => imm_in(6)) & imm_in(6 downto 0);
		elsif jmpl_op='1' then
			opb_nxt <= pc_in;
		else
			opb_nxt <= regb_done;
		end if;
	end process;	
	
sync: process (clk, reset)
	begin
		if reset = '1' then
			opcode_out <= (others => '0');
			dest_out <= (others => '0');
			opa_out <= (others => '0');
			opb_out <= (others => '0');

			rega_out <= (others => '0');
			regb_out <= (others => '0');
		elsif rising_edge(clk) then
			if lock/='1' then
				opcode_out <= opcode_nxt;
				dest_out <= dest_nxt;
				opa_out <= opa_nxt;
				opb_out <= opb_nxt;
			--~ else
				--~ opcode <= opcode;
				--~ dest <= dest;
				--~ opa <= opa;
				--~ opb <= opb;
			rega_out <= rega_nxt;
			regb_out <= regb_nxt;
			end if;
		end if;
	end process;
end sat1;
