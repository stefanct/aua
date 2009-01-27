library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.aua_types.all;

entity id is
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

		-- needed for EX forwarding
		rega_out	: out reg_t;
		regb_out	: out reg_t;

		-- branch decision
		pc_out		: out word_t;
		branch_out	: out std_logic
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
	signal vala			: word_t;
	signal valb			: word_t;
	
	signal regb_done	: word_t;	-- hides r0 changes
	signal jmpl_op		: std_logic; -- set if instr is jmpl. used to propagate $ra to EX
	signal opa_to_nop	: std_logic; -- set if we need opa to be all 0s for idle EX

begin
	cmp_reg : reg
		port map(clk, reset, async_rega, async_regb, rega, regb, regr, valr, vala, valb);
		
		rega_nxt <= rega;
		regb_nxt <= regb;

	branch: process (opcode, opa_nxt, pc, dest, opb_nxt)
		variable inv : std_ulogic;
		variable brinstr : std_ulogic; -- set if op changes PC
	begin
		inv := '0';
		brinstr := '0';

		opa_to_nop <= '0';
		jmpl_op <= '0';
		pc_out <= std_logic_vector(TO_INTEGER(unsigned(pc)) + signed(opb_nxt));

		if opcode(5 downto 3)="010" then
			inv := opcode(2);
			brinstr := '1';
			-- schedule nop
			opcode_nxt <= (others => '0');
			opa_to_nop <= '1';
			dest_nxt <= (others => '0');
		elsif opcode(5 downto 1) ="00111" then
			inv := opcode(0);
			brinstr := '1';
			-- schedule nop
			opcode_nxt <= (others => '0');
			opa_to_nop <= '1';
			dest_nxt <= (others => '0');
		elsif opcode = "001101" then
			inv := '0';
			brinstr := '1';
			-- jmpl, schedule mov r31, pc!
			opcode_nxt <= "111011";
			dest_nxt <= "11111";
			jmpl_op <= '1';
			-- jump is absolute!
			pc_out <= opb_nxt;
		else
			opcode_nxt <= opcode;
			dest_nxt <= dest;
		end if;
		
		if ((std_logic_vector(to_unsigned(0, 16)))=opa_nxt xor inv='1') and brinstr='1' then
			branch_out <= '1';
		else
			branch_out <= '0';
		end if;
	end process;

	-- hide r0 changes
	r0readonly: process (rega, regb, vala, valb, opa_to_nop)
	begin
		if rega="00000" or opa_to_nop = '1' then
			opa_nxt <= (others => '0');
		else
			opa_nxt <= vala;
		end if;

		if regb=(4 downto 0=>'0') then
			regb_done <= (others => '0');
		else
			regb_done <= valb;
		end if;
	end process;

	-- sign extend, expand and mux with regb
	extend: process (opcode, imm,regb_done, jmpl_op, pc)
	begin
		if opcode(5 downto 3)="000" then
			opb_nxt <= (15 downto 8 => '0') & imm(7 downto 0);
		elsif opcode(5 downto 2) ="1100" or opcode(5 downto 0) ="111010" then
			--expand whole imm (alu has to take care if thats "too much")
			opb_nxt <= (15 downto 7 => '0') & imm(6 downto 0);
		elsif opcode(5 downto 4)="01" then
			--sign extend imm(6 downto 0)
			opb_nxt <= (15 downto 7 => imm(6)) & imm(6 downto 0);
		elsif jmpl_op='1' then
			opb_nxt <= pc;
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
			opcode_out <= opcode_nxt;
			dest_out <= dest_nxt;
			opa_out <= opa_nxt;
			opb_out <= opb_nxt;
			rega_out <= rega_nxt;
			regb_out <= regb_nxt;
		end if;
	end process;
end sat1;
