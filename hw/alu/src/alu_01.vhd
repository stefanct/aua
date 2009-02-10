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
	signal carry: 		std_logic;
	signal carry_nxt:	std_logic;
	
	begin
	
sync_carry: process (clk, reset)
	begin
		if reset = '1' then
			carry <= '0';
		elsif rising_edge(clk) then
			carry <= carry_nxt;
		end if;
	end process;
		
	process(opcode, opa, opb, carry)
			variable tmp_carry: 	std_logic_vector(16 downto 0);
			variable tmp_mul:   	std_logic_vector(31 downto 0);
			variable tmp: 			word_t;
			variable tmp_opa:		word_t;
			variable tmp_opb:		word_t;
			variable res_ignore:	word_t;
			variable sgn_a:			std_logic;
			variable sgn_b:			std_logic;
	begin
		carry_nxt <= carry;
		
		sgn_a := '0';
		sgn_b := '0';
		tmp_opa := opa;
		tmp_opb := opb;
		res_ignore := x"0000";
		
		if 	opcode(5 downto 0) = "100100" or 
			opcode(5 downto 0) = "100110" or
			opcode(5 downto 2) = "0111" then
			
			if opa(15) = '1' then
				sgn_a := '1';
				tmp_opa := std_logic_vector(unsigned(not opa) + 1);
			end if;
			if opb(15) = '1' then
				sgn_b := '1';
				tmp_opb := std_logic_vector(unsigned(not opb) + 1);
			end if;
		end if; 
		
			case opcode(5 downto 3) is
				when "000" => -- ldi
					result <= opa(15 downto 8) & opb(7 downto 0);
					
				when "011" => --addi/muli
					if opcode(2) = '0' then --addi
						--result <= std_logic_vector(signed(opa) + signed(opb));
						tmp_carry := std_logic_vector(('0' & unsigned(opa)) + ('0' & unsigned(opb)));
						carry_nxt <= tmp_carry(16);
						result <= tmp_carry(15 downto 0);
						
					else --muli
						tmp_mul := std_logic_vector(unsigned(tmp_opa) * unsigned(tmp_opb));
						if sgn_a /= sgn_b then
							tmp_mul := std_logic_vector(unsigned(not tmp_mul) + 1);
						end if;
						result <= tmp_mul(15 downto 0);
					end if;
					
				when "100" =>
					case opcode(2 downto 0) is
						when "000" => -- add
							tmp_carry := std_logic_vector(('0' & unsigned(opa)) + ('0' & unsigned(opb)) );
							carry_nxt <= tmp_carry(16);
							result <= tmp_carry(15 downto 0);
						
						when "001" => -- addc
							tmp_carry := std_logic_vector(('0' & unsigned(opa)) + ('0' & unsigned(opb)) + (x"0000"&carry));
							carry_nxt <= tmp_carry(16);
							result <= tmp_carry(15 downto 0);
					
						when "010" => --sub
							tmp_carry := std_logic_vector(('0' & unsigned(opa)) - ('0' & unsigned(opb)));
							carry_nxt <= tmp_carry(16);
							result <= tmp_carry(15 downto 0);
					
						when "011" => -- subc
							tmp_carry := std_logic_vector(('0' & unsigned(opa)) - ('0' & unsigned(opb)) - (x"0000"&carry));
							carry_nxt <= tmp_carry(16);
							result <= tmp_carry(15 downto 0);
						
						when "100" => -- mul
							tmp_mul := std_logic_vector(unsigned(tmp_opa) * unsigned(tmp_opb));
							if sgn_a /= sgn_b then
								tmp_mul := std_logic_vector(unsigned(not tmp_mul) + 1);
							end if;
							result <= tmp_mul(15 downto 0);
							
						when "101" => -- mulu
							tmp_mul := std_logic_vector(unsigned(tmp_opa) * unsigned(tmp_opb));
							result <= tmp_mul(15 downto 0);
					
						when "110" => -- mulh
							tmp_mul := std_logic_vector(unsigned(tmp_opa) * unsigned(tmp_opb));
							if sgn_a /= sgn_b then
								tmp_mul := std_logic_vector(unsigned(not tmp_mul) + 1);
							end if;
							result <= tmp_mul(31 downto 16);
					
						when "111" => -- mulhu
							tmp_mul := std_logic_vector(unsigned(tmp_opa) * unsigned(tmp_opb));
							result <= tmp_mul(31 downto 16);
							
						when others =>
							result <= res_ignore;
					end case;
					
				when "101" =>
					case opcode(2 downto 0) is
						when "000" => -- or 
							result <= opa or opb;
					
						when "001" => -- and
							result <= opa and opb;
					
						when "010" => -- xor
							result <= opa xor opb;
					
						when "011" => -- not
							result <= not opb;
					
						when "100" => -- neg
							result <= std_logic_vector(unsigned(not opb) + 1); 
					
						when "101" => -- asr
							result <= to_stdlogicvector(to_bitvector(opb) sra 1);
					
						when "110" => -- lsl
							result <= std_logic_vector(unsigned(opb) sll 1);
					
						when "111" => -- lsr
							result <= std_logic_vector(unsigned(opb) srl 1);
						
						when others =>
							result <= res_ignore;
					end case;
					
				when "110" =>
					case opcode(2 downto 0) is
						when "000" => -- lsli
							result <= std_logic_vector(unsigned(opa) sll to_integer(unsigned(opb(3 downto 0)))); 
					
						when "001" => -- lsri
							result <= std_logic_vector(unsigned(opa) srl to_integer(unsigned(opb(3 downto 0))));
					
						when "010" => -- scb
							tmp := std_logic_vector(to_unsigned(2**to_integer(unsigned(opb(3 downto 0))),word_t'length));
							if opb(4) = '1' then
								result <= opa or tmp;
							else
								result <= opa and (not tmp);
							end if;
					
						when "011" => -- roti
							if opb(4) = '0' then -- rotl
								result <= std_logic_vector(unsigned(opa) rol to_integer(unsigned(opb(3 downto 0))));
							else -- rotr
								result <= std_logic_vector(unsigned(opa) ror to_integer(unsigned(opb(3 downto 0))));
							end if;
						
--						when "100" => --cmpv
							
						when "101" => -- cmplt
							if signed(opa) < signed(opb) then
								result <= x"0001";
							else
								result <= x"0000";
							end if;
					
						when "110" => -- cmpltu
							if opa < opb then
								result <= x"0001";
							else
								result <= x"0000";
							end if;
					
						when "111" => -- cmplte
							if signed(opa) <= signed(opb) then
								result <= x"0001";
							else
								result <= x"0000";
							end if;
							
						when others =>
							result <= res_ignore;
					end case;
					
				when "111" =>
					case opcode(2 downto 0) is-- cmplteu
						when "000" =>
							if opa <= opb then
								result <= x"0001";
							else
								result <= x"0000";
							end if;
					
						when "001" => -- cmpe
							if opa = opb then
								result <= x"0001";
							else
								result <= x"0000";
							end if;
							
						when "010" => -- cmpei
							if opa = ((15 downto 5 => '0')&opb(4 downto 0))  then
								result <= x"0001";
							else
								result <= x"0000";
							end if;
							
						when "011" => 
								result <= opb;-- mov
						
						when others =>
								result <= res_ignore;
					end case;
					
				when others => 
					result <= res_ignore;
			end case;
-- others 
--				when "001101" => result <= x"0000";-- jmpl
--				when "001110" => result <= x"0000";-- brez
--				when "001111" => result <= x"0000";-- brnez
--				when "010000" => result <= x"0000";-- brezi
--				when "010001" => result <= x"0000";-- brezi
--				when "010010" => result <= x"0000";-- brezi
--				when "010011" => result <= x"0000";-- brezi
--				when "010100" => result <= x"0000";-- brnezi
--				when "010101" => result <= x"0000";-- brnezi
--				when "010110" => result <= x"0000";-- brnezi
--				when "010111" => result <= x"0000";-- brnezi 
--				when "111100" => result <= x"0000";-- ld
--				when "111101" => result <= x"0000";-- ldb
--				when "111110" => result <= x"0000";-- st
--				when "111111" => result <= x"0000";-- stb
--				when "110100" => result <= x"0000";-- cmpv
		end process;
    end sat1;