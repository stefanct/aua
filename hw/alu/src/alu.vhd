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
	signal C: bit;
	--constant max_value : integer := 2**word_t'length - 1;
	--constant min_value : integer := -2**(word_t'length-1); --so irgendwas halt... falls dus ueberhaupt brauchst
	constant max_value: integer := 2**15-1;
	constant min_value: integer := -2**15;
	
--	function calc_overflow(a: in word_t; b: in word_t) return bit is
--	begin
--		if signed(a) > (max_value - signed(b)) and signed(b) > 0 then
--			return '1';
--		elsif signed(a) < (min_value - signed(b)) and signed(b) < 0 then
--			return '1';
--		else
--			return '0';
--		end if;
--	end function;
	
	begin
		process(opcode, opa, opb,C)
			variable tmp: word_t;
			variable tmp_reg: std_logic_vector(16 downto 0);
		begin
			C <= '0';
			case opcode(5 downto 0) is
				when "011000" => --addi
					result <= std_logic_vector(signed(opa) + signed(opb));
				   
				when "011001" => --addi
					result <= std_logic_vector(signed(opa) + signed(opb));
					
				when "011010" => --addi
					result <= std_logic_vector(signed(opa) + signed(opb));
					
				when "011011" => --addi
					result <= std_logic_vector(signed(opa) + signed(opb));
					
				when "011100" => result <= x"0000";-- muli
				when "011101" => result <= x"0000";-- muli
				when "011110" => result <= x"0000";-- muli
				when "011111" => result <= x"0000";-- muli
					
				when "100000" => -- add
					tmp_reg := std_logic_vector(('0' & unsigned(opa)) + ('0' & unsigned(opb)));
					C <= to_bit(tmp_reg(16));
					result <= tmp_reg(15 downto 0);
					
				when "100001" => -- addc
					tmp_reg := std_logic_vector(('0' & unsigned(opa)) + ('0' & unsigned(opb)));
					if C = '1' then
						tmp_reg := std_logic_vector(unsigned(tmp_reg) + to_unsigned(1,tmp_reg'length));
					end if;
					C <= to_bit(tmp_reg(16));
					result <= tmp_reg(15 downto 0);
					
				when "100010" => --sub
					tmp_reg := std_logic_vector(('0' & unsigned(opa)) - ('0' & unsigned(opb)));
					C <= to_bit(tmp_reg(16));
					result <= tmp_reg(15 downto 0);
					
				when "100011" => -- subc
					tmp_reg := std_logic_vector(('0' & unsigned(opa)) - ('0' & unsigned(opb)));
					if C = '1' then
						tmp_reg := std_logic_vector(unsigned(tmp_reg) - to_unsigned(1,tmp_reg'length));
					end if;
					C <= to_bit(tmp_reg(16));
					result <= tmp_reg(15 downto 0);
					
				when "100100" => -- mul
					result <= x"0000";
					
				when "100101" => -- mulu
					result <= x"0000";
					
				when "100110" => -- mulh
					result <= x"0000";
					
				when "100111" => -- mulhu
					result <= x"0000";
					
				when "101000" => -- or 
					result <= opa or opb;
					
				when "101001" => -- and
					result <= opa and opb;
					
				when "101010" => -- xor
					result <= opa xor opb;
					
				when "101011" => -- not
					result <= not opb;
					
				when "101100" => -- neg
--					if opb = x"0000" then
--						result <= x"0000";
--					else
--						tmp := not opb;    
--						tmp := std_logic_vector(unsigned(tmp) + 1);
--						if opb(15) = '1' and tmp(15) = '1' then
--							V <= '1';
--						end if;
--						result <= tmp;
--					end if;
					result <= std_logic_vector(unsigned(opb) + 1); 
					
				when "101101" => -- asr
					result <= to_stdlogicvector(to_bitvector(opb) sra 1);
					
				when "101110" => -- lsl
					result <= std_logic_vector(unsigned(opb) sll 1);
					
				when "101111" => -- lsr
					result <= std_logic_vector(unsigned(opb) srl 1);
					
				when "110000" => -- lsli
					result <= std_logic_vector(unsigned(opa) sll to_integer(unsigned(opb(3 downto 0)))); 
					
				when "110001" => -- lsri
					result <= std_logic_vector(unsigned(opa) srl to_integer(unsigned(opb(3 downto 0))));
					
				when "110010" => -- scb
					tmp := x"0000";
					tmp(to_integer(unsigned(opb(3 downto 0)))) := '1';
					if opb(4) = '1' then -- set
						result <= opa or tmp;
					else -- clear
						tmp := not tmp;
						result <= opa and tmp;
					end if;
					
				when "110011" => -- roti
					if opb(4) = '0' then -- rotl
						result <= std_logic_vector(unsigned(opa) rol to_integer(unsigned(opb(3 downto 0))));
					else -- rotr
						result <= std_logic_vector(unsigned(opa) ror to_integer(unsigned(opb(3 downto 0))));
					end if;
				
--				when "110100" => -- cmpv
--					if V = '1' then
--						result <= x"0001";
--					else
--						result <= x"0000";
--					end if;  
					
				when "110101" => -- cmplt
					if signed(opa) < signed(opb) then
						result <= x"0001";
					else
						result <= x"0000";
					end if;
					
				when "110110" => -- cmpltu
					if opa < opb then
						result <= x"0001";
					else
						result <= x"0000";
					end if;
					
				when "110111" => -- cmplte
					if signed(opa) <= signed(opb) then
						result <= x"0001";
					else
						result <= x"0000";
					end if;
					
				when "111000" => -- cmplteu
					if opa <= opb then
						result <= x"0001";
					else
						result <= x"0000";
					end if;
					
				when "111001" => -- cmpe
					if opa = opb then
						result <= x"0001";
					else
						result <= x"0000";
					end if;
					
				when "111010" => -- cmpei
				-- wie gehtn das richtig?
					if opa = (("00000000000") & opb(4 downto 0)) then
						result <= x"0001";
					else
						result <= x"0000";
					end if;
						
				when "000000" => result <= x"0000";-- ldi
					when "000001" => result <= x"0000";-- ldi
					when "000010" => result <= x"0000";-- ldi
					when "000011" => result <= x"0000";-- ldi
					when "000100" => result <= x"0000";-- ldi
					when "000101" => result <= x"0000";-- ldi
					when "000110" => result <= x"0000";-- ldi
					when "000111" => result <= x"0000";-- ldi
				when "001101" => result <= x"0000";-- jmpl
				when "001110" => result <= x"0000";-- brez
				when "001111" => result <= x"0000";-- brnez
				when "010000" => result <= x"0000";-- brezi
					when "010001" => result <= x"0000";-- brezi
					when "010010" => result <= x"0000";-- brezi
					when "010011" => result <= x"0000";-- brezi
				when "010100" => result <= x"0000";-- brnezi
					when "010101" => result <= x"0000";-- brnezi
					when "010110" => result <= x"0000";-- brnezi
					when "010111" => result <= x"0000";-- brnezi 
				when "111011" => result <= opb;-- mov
				when "111100" => result <= x"0000";-- ld
				when "111101" => result <= x"0000";-- ldb
				when "111110" => result <= x"0000";-- st
				when "111111" => result <= x"0000";-- stb
				when "110100" => result <= x"0000";-- cmpv
				when others => result <= x"0000";
			end case;
		end process;
    end sat1;
