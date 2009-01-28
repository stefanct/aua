library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.aua_types.all;

entity ent_if is
	port (
		clk     : in std_logic;
		reset	: in std_logic;

		-- pipeline register outputs
		opcode_out	: out opcode_t;
		dest_out	: out reg_t;
		pc_out		: out word_t;
		rega_out	: out reg_t;
		regb_out	: out reg_t;
		imm_out		: out std_logic_vector(7 downto 0);

		-- asynchron register outputs
		async_rega	: out reg_t;
		async_regb	: out reg_t;
			
		-- branches (from ID)
		pc_in		: in word_t;
		branch		: in std_logic;

		-- cache
		instr_addr	: out word_t;
		instr_valid	: in std_logic;
		instr_data	: in word_t;
		
		-- interlock
		lock	: in std_logic
	);
end ent_if;

architecture sat1 of ent_if is
	signal opcode_nxt	: opcode_t;
	signal dest_nxt		: reg_t;
	signal rega_nxt		: reg_t;
	signal regb_nxt		: reg_t;
	signal imm_nxt		: std_logic_vector(7 downto 0);
	signal pc_nxt		: word_t;
	
	signal opcode	: opcode_t;
	signal dest		: reg_t;
	signal rega		: reg_t;
	signal regb		: reg_t;
	signal imm		: std_logic_vector(7 downto 0);
	signal pc	: word_t;
begin

	instr_dec: process(reset, instr_data, branch, instr_valid)
	begin
		if branch = '0' and instr_valid = '1' then
			opcode_nxt <= instr_data(15 downto 10);
			dest_nxt <= instr_data(4 downto 0);
			rega_nxt <= instr_data(4 downto 0);
			regb_nxt <= instr_data(9 downto 5);
			imm_nxt <= instr_data(12 downto 5);
		else -- schedule nop, we wait for a (re)fetch
			opcode_nxt <= (others => '0');
			dest_nxt <= (others => '0');
			rega_nxt <= (others => '0');
			regb_nxt <= (others => '0');
			imm_nxt <= (others => '0');
		end if;
	end process;
	async_rega <= rega_nxt;
	async_regb <= regb_nxt;
	
	instr_addr <= pc;

	opcode_out <= opcode;
	dest_out <= dest;
	rega_out <= rega;
	regb_out <= regb;
	imm_out <= imm;

	calc_pc_nxt: process(reset, pc, pc_in, branch, instr_valid)
	begin
		if reset = '1' then
			pc_nxt <= (others => '0');
			--~ pc_nxt <= x"8000"; -- direkt in ROM
		elsif branch='1' then
			pc_nxt <= pc_in;
		elsif instr_valid /= '1' then
			pc_nxt <= pc;
		else
			pc_nxt <= std_logic_vector(unsigned(pc) + 2);
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
			--~ pc <= (others => '0');
			pc <= x"8000";
			--~ pc <= x"7FFE";
			--~ pc <= pc_nxt;
			--~ instr_addr <= (others => '0');
			pc_out <= (others => '0');
		elsif rising_edge(clk) then
			if lock='1' then
				opcode <= opcode;
				dest <= dest;
				rega <= rega;
				regb <= regb;
				imm <= imm;

				pc <= pc;
			else
				opcode <= opcode_nxt;
				dest <= dest_nxt;
				rega <= rega_nxt;
				regb <= regb_nxt;
				imm <= imm_nxt;

				pc <= pc_nxt;
			end if;

			pc_out <= pc;
		end if;
	end process;
end sat1;
