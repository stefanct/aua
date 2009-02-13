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

architecture sat1 of alu is
	component Mux32to1 is
		port(	
			i01: in std_logic_vector(15 downto 0);
			i02: in std_logic_vector(15 downto 0);
			i03: in std_logic_vector(15 downto 0);
			i04: in std_logic_vector(15 downto 0);
			i05: in std_logic_vector(15 downto 0);
			i06: in std_logic_vector(15 downto 0);
			i07: in std_logic_vector(15 downto 0);
			i08: in std_logic_vector(15 downto 0);
			i09: in std_logic_vector(15 downto 0);
			i10: in std_logic_vector(15 downto 0);
			i11: in std_logic_vector(15 downto 0);
			i12: in std_logic_vector(15 downto 0);
			i13: in std_logic_vector(15 downto 0);
			i14: in std_logic_vector(15 downto 0);
			i15: in std_logic_vector(15 downto 0);
			i16: in std_logic_vector(15 downto 0);
			i17: in std_logic_vector(15 downto 0);
			i18: in std_logic_vector(15 downto 0);
			i19: in std_logic_vector(15 downto 0);
			i20: in std_logic_vector(15 downto 0);
			i21: in std_logic_vector(15 downto 0);
			i22: in std_logic_vector(15 downto 0);
			i23: in std_logic_vector(15 downto 0);
			i24: in std_logic_vector(15 downto 0);
			i25: in std_logic_vector(15 downto 0);
			i26: in std_logic_vector(15 downto 0);
			i27: in std_logic_vector(15 downto 0);
			i28: in std_logic_vector(15 downto 0);
			i29: in std_logic_vector(15 downto 0);
			i30: in std_logic_vector(15 downto 0);
			i31: in std_logic_vector(15 downto 0);
			i32: in std_logic_vector(15 downto 0);
			sel: in std_logic_vector(4 downto 0);
			mux_out: out std_logic_vector(15 downto 0)
		);
	end component;
	
	signal carry: 		std_logic;
	signal carry_nxt:	std_logic;
	signal mux_sel:		std_logic_vector(4 downto 0);
	signal mux1_o:		word_t;
	
	signal res_ldi: 	word_t;
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
	signal res_ignore:	word_t;
	
begin
	mux1: Mux32to1 port map
	(	res_ldi, 
		res_add, 
		res_mul, 
		res_add, 
		res_addc, 
		res_sub, 
		res_subc, 
		res_mul, 
		res_mulu,
		res_mulh, 
		res_mulhu, 
		res_or, 
		res_and, 
		res_xor, 
		res_not, 
		res_neg, 
		res_asr, 
		res_lsl, 
		res_lsr,
		res_lsli, 
		res_lsri, 
		res_scb, 
		res_roti, 
		res_cmplt, 
		res_cmpltu, 
		res_cmplte, 
		res_cmplteu,
		res_cmpe, 
		res_cmpei, 
		res_mov, 
		res_ignore, 
		res_ignore, 
		mux_sel, 
		mux1_o
	);
	
sync_carry: process (clk, reset)
begin
	if reset = '1' then
		carry <= '0';
	elsif rising_edge(clk) then
		carry <= carry_nxt;
	end if;
end process;

process(opcode, opa, opb, carry, mux1_o)
	variable tmp_sel: std_logic_vector(4 downto 0);
	
	variable tmp_opa: 	std_logic_vector(16 downto 0);
	variable tmp_opb: 	std_logic_vector(16 downto 0);
	variable tmp_addc:	std_logic_vector(16 downto 0);
	variable tmp_subc:	std_logic_vector(16 downto 0);
	variable tmp_carry: std_logic_vector(16 downto 0);
	variable carry_addc:std_logic;
	variable carry_subc:std_logic;
	variable tmp_muls:	std_logic_vector(31 downto 0);
	variable tmp_mulu:	std_logic_vector(31 downto 0);
	variable tmp_scb:	word_t;
	variable tmp_sll:	word_t;
	variable tmp_srl:	word_t;
	
begin 
		res_ldi <= opa(15 downto 8) & opb(7 downto 0); 
--------------------------------------------------------------------------------------------------
		tmp_opa := std_logic_vector(('0' & opa));
		tmp_opb := std_logic_vector(('0' & opb));
		
		if (opcode = "100001") or (opcode = "100011") then
			tmp_carry := (x"0000"&carry);
		else
			tmp_carry := (16 downto 0 => '0');
		end if;

		tmp_addc := std_logic_vector(unsigned(tmp_opa) + unsigned(tmp_opb) + unsigned(tmp_carry));
		tmp_subc := std_logic_vector(unsigned(tmp_opa) - unsigned(tmp_opb) - unsigned(tmp_carry));
		carry_addc := tmp_addc(16);
		carry_subc := tmp_subc(16);
		res_add <= tmp_addc(15 downto 0);
		res_addc <= tmp_addc(15 downto 0);
		res_sub <= tmp_subc(15 downto 0);
		res_subc <= tmp_subc(15 downto 0);

		if opcode = "100001" or opcode = "011000" or opcode = "100000" then
			carry_nxt <= carry_addc;
		elsif opcode = "100011" or opcode = "100010" then
			carry_nxt <= carry_subc;
		else
			carry_nxt <= '0';
		end if;
--------------------------------------------------------------------------------------------------
--		tmp_add := std_logic_vector(('0' & unsigned(opa)) + ('0' & unsigned(opb)));
--		tmp_addc := std_logic_vector(('0' & unsigned(opa)) + ('0' & unsigned(opb)) + (x"0000"&carry));
--		carry_add := tmp_add(16);
--		carry_addc := tmp_addc(16);
--		
--		res_add <= tmp_add(15 downto 0);
--		res_addc <= tmp_addc(15 downto 0);
--		
--		tmp_sub := std_logic_vector(('0' & unsigned(opa)) - ('0' & unsigned(opb)));
--		tmp_subc := std_logic_vector(('0' & unsigned(opa)) - ('0' & unsigned(opb)) - (x"0000"&carry));
--		carry_sub := tmp_sub(16);
--		carry_subc := tmp_subc(16);
--		
--		res_sub <= tmp_sub(15 downto 0);
--		res_subc <= tmp_subc(15 downto 0); 
--------------------------------------------------------------------------------------------------
		tmp_muls := std_logic_vector(signed(opa) * signed(opb));
		tmp_mulu := std_logic_vector(unsigned(opa) * unsigned(opb));
		
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
		
		tmp_scb := opa;
		tmp_scb(to_integer(unsigned(opb(3 downto 0)))) := opb(4);
		res_scb <= tmp_scb;
		
		if opb(4) = '0' then -- rotl
			res_roti <= std_logic_vector(unsigned(opa) rol to_integer(unsigned(opb(3 downto 0))));
		else -- rotr
			res_roti <= std_logic_vector(unsigned(opa) ror to_integer(unsigned(opb(3 downto 0))));
		end if;
		
		if signed(opa) < signed(opb) then
			res_cmplt <= x"0001"; 
		else
			res_cmplt <= x"0000";
		end if;
		
		if unsigned(opa) < unsigned(opb) then
			res_cmpltu <= x"0001";
		else
			res_cmpltu <= x"0000";
		end if;
		
		if signed(opa) <= signed(opb) then
			res_cmplte <= x"0001";
		else
			res_cmplte <= x"0000";
		end if;
		
		if unsigned(opa) <= unsigned(opb) then
			res_cmplteu <= x"0001";
		else
			res_cmplteu <= x"0000";
		end if;
		 
		if opa = opb then
			res_cmpe <= x"0001";
		else
			res_cmpe <= x"0000";
		end if;
		
		if opa = ((15 downto 5 => '0')&opb(4 downto 0))  then
			res_cmpei <= x"0001";
		else
			res_cmpei <= x"0000";
		end if;
		
		res_mov <= opb;
		
		res_ignore <= x"0000";
		
		case opcode(5 downto 3) is
			when "000" => tmp_sel := "00000"; --ldi
			--when "001" => tmp_sel := "11110"; branches--ignore
			--when "010" => tmp_sel := "11110"; --ignore
			when "011" =>
				case opcode(2 downto 0) is
					when "000" => tmp_sel := "00001"; --addi
					when "001" => tmp_sel := "00001"; --addi
					when "010" => tmp_sel := "00001"; --addi
					when "011" => tmp_sel := "00001"; --addi
					when "100" => tmp_sel := "00010"; --muli
					when "101" => tmp_sel := "00010"; --muli
					when "110" => tmp_sel := "00010"; --muli
					when "111" => tmp_sel := "00010"; --muli
					when others => tmp_sel := "11110"; --ignore
				end case;
			when "100" =>
				case opcode(2 downto 0) is
					when "000" => tmp_sel := "00011"; --add
					when "001" => tmp_sel := "00100"; --addc
					when "010" => tmp_sel := "00101"; --sub
					when "011" => tmp_sel := "00110"; --subc
					when "100" => tmp_sel := "00111"; --mul
					when "101" => tmp_sel := "01000"; --mulu
					when "110" => tmp_sel := "01001"; --mulh
					when "111" => tmp_sel := "01010"; --mulhu
					when others => tmp_sel := "11110"; --ignore
				end case;
			when "101" =>
				case opcode(2 downto 0) is
					when "000" => tmp_sel := "01011"; --or
					when "001" => tmp_sel := "01100"; --and
					when "010" => tmp_sel := "01101"; --xor
					when "011" => tmp_sel := "01110"; --not
					when "100" => tmp_sel := "01111"; --neg
					when "101" => tmp_sel := "10000"; --asr
					when "110" => tmp_sel := "10001"; --lsl
					when "111" => tmp_sel := "10010"; --lsr
					when others => tmp_sel := "11110"; --ignore
				end case;
			when "110" =>
				case opcode(2 downto 0) is
					when "000" => tmp_sel := "10011"; --lsli
					when "001" => tmp_sel := "10100"; --lsri
					when "010" => tmp_sel := "10101"; --scb
					when "011" => tmp_sel := "10110"; --roti
					when "100" => tmp_sel := "10111"; --cmplt
					when "101" => tmp_sel := "11000"; --cmpltu
					when "110" => tmp_sel := "11001"; --cmplte
					when "111" => tmp_sel := "11010"; --cmplteu
					when others => tmp_sel := "11110"; --ignore
				end case;
			when "111" =>
				case opcode(2 downto 0) is
					when "000" => tmp_sel := "11011"; --cmpe
					when "001" => tmp_sel := "11100"; --cmpei
					when "010" => tmp_sel := "11110"; --ignore
					when "011" => tmp_sel := "11101"; --mov
					when "100" => tmp_sel := "11110"; --ld, ignore
					when "101" => tmp_sel := "11110"; --ldb, ignore
					when "110" => tmp_sel := "11110"; --st, ignore
					when "111" => tmp_sel := "11110"; --stb, ignore
					when others => tmp_sel := "11110"; --ignore
				end case;
			when others => tmp_sel := "11110"; --ignore
		end case;
		
		mux_sel <= tmp_sel;
		result <= mux1_o;
		
	end process;
end sat1;
