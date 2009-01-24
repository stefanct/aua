library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.aua_types.all;

entity ent_if is
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

		-- cache
		instr_addr	: out word_t;
		instr_valid	: in std_logic;
		instr_data	: in word_t

	);
end ent_if;

architecture sat1 of ent_if is
	signal opcode_nxt	: opcode_t;
	signal dest_nxt		: reg_t;
	signal rega_nxt		: reg_t;
	signal regb_nxt		: reg_t;
	signal imm_nxt		: std_logic_vector(7 downto 0);

	signal pc		: word_t;
	signal pc_nxt	: word_t;
begin

	opcode_nxt <= instr_data(15 downto 10);
	dest_nxt <= instr_data(4 downto 0);
	rega_nxt <= instr_data(4 downto 0);
	regb_nxt <= instr_data(9 downto 5);
	imm_nxt <= instr_data(12 downto 5);
	async_rega <= rega_nxt;
	async_regb <= regb_nxt;
	
	instr_addr <= pc;
	pc_out <= pc;

	process(reset, pc, pc_in, branch, instr_valid)
	begin
		if reset = '1' then
			pc_nxt <= (others => '0');
		elsif instr_valid /= '1' then
			pc_nxt <= pc;
		else
			if branch='1' then
				pc_nxt <= pc_in;
			else
				pc_nxt <= std_logic_vector(unsigned(pc) + 2);
			end if;
		end if;
	end process;

	process(clk, reset)
	begin
		if reset = '1' then
			opcode <= (others => '0');
			dest <= (others => '0');
			rega <= (others => '0');
			regb <= (others => '0');
			imm <= (others => '0');
			pc <= (others => '0');
		elsif rising_edge(clk) then
			opcode <= opcode_nxt;
			dest <= dest_nxt;
			rega <= rega_nxt;
			regb <= regb_nxt;
			imm <= imm_nxt;
			pc <= pc_nxt;
		end if;
	end process;
end sat1;
