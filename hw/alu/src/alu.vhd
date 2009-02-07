library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.aua_types.all;
	
entity alu is
	port (
		clk		: in	std_logic;
		reset	: in	std_logic;
		opcode	: in	opcode_t;
		opa		: in	word_t;
		opb		: in	word_t;
		result	: out	word_t
	);
end alu;

architecture rtl of alu is
signal carry: 		std_logic;
signal carry_nxt:	std_logic;

signal carry_add:	std_logic;
signal carry_sub:	std_logic;
signal carry_addc:	std_logic;
signal carry_subc:	std_logic;
signal carry_addi:	std_logic;

signal res_ldi: 	word_t;
signal res_jmpl:	word_t;
signal res_brez:	word_t;
signal res_brnez:	word_t;
signal res_brezi:	word_t;
signal res_brnezi:	word_t;
signal res_addi:	word_t;
signal res_muli:	word_t;
signal res_add:		word_t;
signal res_addc:	word_t;
signal res_sub:		word_t;
signal res_subc:	word_t;
signal res_mul:		word_t;
signal res_mulu:	word_t;
signal res_mulh:	word_t;
signal res_mulhu:	word_t;
signal res_or:		word_t;
signal res_and:		word_t;
signal res_xor:		word_t;
signal res_not:		word_t;
signal res_neg:		word_t;
signal res_asr:		word_t;
signal res_lsl:		word_t;
signal res_lsr:		word_t;
signal res_lsli:	word_t;
signal res_lsri:	word_t;
signal res_scb:		word_t;
signal res_roti:	word_t;
signal res_cmplt:	word_t;
signal res_cmpltu:	word_t;
signal res_cmplte:	word_t;
signal res_cmplteu:	word_t;
signal res_cmpe:	word_t;
signal res_cmpei:	word_t;
signal res_mov:		word_t;
signal res_ld:		word_t;
signal res_ldb:		word_t;
signal res_st:		word_t;
signal res_stb:		word_t;

begin

sync_carry: process (clk, reset)
begin
	if reset = '1' then
		carry <= '0';
	elsif rising_edge(clk) then
		carry <= carry_nxt;
	end if;
end process;

select_result:process(clk, reset, opcode, carry) 
begin
	if reset = '1' then
		result <= x"0000";
	elsif rising_edge(clk) then
		carry_nxt <= carry;
		case opcode(5 downto 3) is
			when "000" => result <= res_ldi; 
			when "001" =>
				case opcode(2 downto 0) is
					when "000" => result <= x"0000";
					when "001" => result <= x"0000";
					when "010" => result <= x"0000";
					when "011" => result <= x"0000";
					when "100" => result <= x"0000";
					when "101" => result <= res_jmpl;
					when "110" => result <= res_brez;
					when "111" => result <= res_brnez;
					when others => result <= x"0000";
				end case;
			when "010" =>
				if opcode(2) = '0' then
					result <= res_brezi;
				else
					result <= res_brnezi;
				end if;
			when "011" =>
				if opcode(2) = '0' then
					result <= res_addi;
					carry_nxt <= carry_addi;
				else
					result <= res_muli;
				end if;
			when "100" =>
				case opcode(2 downto 0) is
					when "000" =>	result <= res_add;
									carry_nxt <= carry_add;
					when "001" => 	result <= res_addc;
									carry_nxt <= carry_addc;
					when "010" => 	result <= res_sub;
									carry_nxt <= carry_sub;
					when "011" => 	result <= res_subc;
									carry_nxt <= carry_subc;
					when "100" => result <= res_mul;
					when "101" => result <= res_mulu;
					when "110" => result <= res_mulh;
					when "111" => result <= res_mulhu;
					when others => result <= x"0000";
				end case;
			when "101" =>
				case opcode(2 downto 0) is
					when "000" => result <= res_or;
					when "001" => result <= res_and;
					when "010" => result <= res_xor;
					when "011" => result <= res_not;
					when "100" => result <= res_neg;
					when "101" => result <= res_asr;
					when "110" => result <= res_lsl;
					when "111" => result <= res_lsr;
					when others => result <= x"0000";
				end case;
			when "110" =>
				case opcode(2 downto 0) is
					when "000" => result <= res_lsli;
					when "001" => result <= res_lsri;
					when "010" => result <= res_scb;
					when "011" => result <= res_roti;
					when "100" => result <= x"0000";
					when "101" => result <= res_cmplt;
					when "110" => result <= res_cmpltu;
					when "111" => result <= res_cmplte;
					when others => result <= x"0000";
				end case;
			when "111" =>
				case opcode(2 downto 0) is
					when "000" => result <= res_cmplteu;
					when "001" => result <= res_cmpe;
					when "010" => result <= res_cmpei;
					when "011" => result <= res_mov;
					when "100" => result <= res_ld;
					when "101" => result <= res_ldb;
					when "110" => result <= res_st;
					when "111" => result <= res_stb;
					when others => result <= x"0000";
				end case;
			when others => result <= x"0000";
		end case;
	end if;
end process;

calc_result: process(carry, opa, opb)
	variable tmp_scb: word_t;
	variable tmp_mulu:	std_logic_vector(31 downto 0);
	variable tmp_muls:	std_logic_vector(31 downto 0);
	variable tmp_muli:	std_logic_vector(31 downto 0);
	variable tmp_addi:	std_logic_vector(16 downto 0);
	variable tmp_add:	std_logic_vector(16 downto 0);
	variable tmp_sub:	std_logic_vector(16 downto 0);
	variable tmp_addc:	std_logic_vector(16 downto 0);
	variable tmp_subc:	std_logic_vector(16 downto 0);
	
begin
	res_ldi <= opa(15 downto 8) & opb(7 downto 0);
	res_jmpl <= x"0000"; -- do nothing
	res_brez <= x"0000"; -- do nothing
	res_brezi <= x"0000"; -- do nothing
	res_brnez <= x"0000"; -- do nothing
	res_brnezi <= x"0000"; -- do nothing
	
	tmp_addi := std_logic_vector(signed(opa(15)&opa) + signed(opb(15)&opb));
	res_addi <= tmp_addi(15 downto 0);
	carry_addi <= tmp_addi(16);
	
	tmp_muli := std_logic_vector(signed(opa) * signed(std_logic_vector'((15 downto 6 => opb(6))&opb(5 downto 0))));
	res_muli <=  tmp_muli(15 downto 0);
	
	tmp_add := std_logic_vector(('0'&unsigned(opa)) + ('0'&unsigned(opb)));
	tmp_addc := std_logic_vector(('0'&unsigned(opa)) + ('0'&unsigned(opb)) + (x"0000"&carry));
	carry_add <= tmp_add(16);
	carry_addc <= tmp_addc(16);
	res_add <= tmp_add(15 downto 0);
	res_addc <= tmp_addc(15 downto 0);
	
	tmp_sub := std_logic_vector(('0'&unsigned(opa)) - ('0'&unsigned(opb)));
	tmp_subc := std_logic_vector(('0'&unsigned(opa)) - ('0'&unsigned(opb)) - (x"0000"&carry));
	carry_sub <= tmp_sub(16);
	carry_subc <= tmp_subc(16);
	res_sub <= tmp_sub(15 downto 0);
	res_subc <= tmp_subc(15 downto 0);
	
	tmp_mulu := std_logic_vector(unsigned(opa) * unsigned(opb));
	tmp_muls := std_logic_vector(signed(opa) * signed(opb));
	res_mul <= tmp_muls(15 downto 0);
	res_mulu <= tmp_mulu(15 downto 0);
	res_mulh <= tmp_muls(31 downto 16);
	res_mulhu <= tmp_mulu(31 downto 16);

	res_or <= opa or opb;
	res_and <= opa and opb;
	res_xor <= opa xor opb;
	res_not <= not opb;
	res_neg <= std_logic_vector(unsigned(not opb) + 1);
	res_asr <= to_stdlogicvector(to_bitvector(opb) sra 1);
	res_lsl <= std_logic_vector(unsigned(opb) sll 1);
	res_lsr <= std_logic_vector(unsigned(opb) srl 1);
	res_lsli <= std_logic_vector(unsigned(opa) sll to_integer(unsigned(opb(3 downto 0))));
	res_lsri <= std_logic_vector(unsigned(opa) srl to_integer(unsigned(opb(3 downto 0))));

	tmp_scb := x"0001";
	tmp_scb := std_logic_vector(unsigned(tmp_scb) sll to_integer(unsigned(opb(3 downto 0))));
	if opb(4) = '1' then
		res_scb <= opa or tmp_scb;
	else
		res_scb <= opa and (not tmp_scb);
	end if;

	if opb(4) = '0' then -- rotl
		res_roti <= std_logic_vector(unsigned(opa) rol to_integer(unsigned(opb(3 downto 0))));
	else -- rotr
		res_roti <= std_logic_vector(unsigned(opa) ror to_integer(unsigned(opb(3 downto 0))));
	end if;

	if signed(opa) < signed (opb) then
		res_cmplt <= x"0001";
	else
		res_cmplt <= x"0000";
	end if;

	if opa < opb then
		res_cmpltu <= x"0001";
	else
		res_cmpltu <= x"0000";
	end if;

	if signed(opa) <= signed (opb) then
		res_cmplte <= x"0001";
	else
		res_cmplte <= x"0000";
	end if;

	if opa <= opb then
		res_cmplteu <= x"0001";
	else
		res_cmplteu <= x"0000";
	end if;

	if opa = opb then
		res_cmpe <= x"0001";
	else
		res_cmpe <= x"0000";
	end if;

	if opa = ((15 downto 5 => '0')&opb(4 downto 0)) then
		res_cmpei <= x"0001";
	else
		res_cmpei <= x"0000";
	end if;

	res_mov <= opb;

	res_ld <= x"0000"; -- do nothing
	res_ldb <= x"0000"; -- do nothing
	res_st <= x"0000"; -- do nothing
	res_stb <= x"0000"; -- do nothing
end process;

end rtl;
