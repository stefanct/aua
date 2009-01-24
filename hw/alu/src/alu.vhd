library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.aua_types.all;

entity alu is
	port (
		clk     : in std_logic;
		reset	: in std_logic;
		opcode	: in opcode_t;
		opa		: in word_t;
		opb		: in word_t;
		result	: out word_t
	);
end alu;

architecture sat1 of alu is

	signal V: bit;
	signal C: bit;
	constant max_value : integer := 2**word_t'length - 1;
	constant min_value : integer := -2**(word_t'length-1); --so irgendwas halt... falls dus ueberhaupt brauchst

begin
	
	process(opcode, opa, opb)
		variable tmp: word_t;
	begin
		V <= '0';
		C <= '0';
		case opcode(5 downto 0) is
			when "001101" => -- jmpl
				result <= x"0000";
			when "001110" => -- brez
				result <= x"0000";
			when "001111" => -- brnez
				result <= x"0000";
			when "100000" => -- add
				if signed(opa) > (max_value - signed(opb)) and signed(opb) > 0 then
					V <= '1';
				elsif signed(opa) < (min_value - signed(opb)) and signed(opb) < 0 then
					V <= '1';
				else
					V <= '0';
				end if;
				result <= NULL;
			when "100001" => -- addc
				result <= NULL;
			when "100010" => -- sub
				if signed(opa) > (max_value + signed(opb)) and signed(opb) < 0 then
					V <= '1';
				elsif signed(opa) < (min_value + signed(opb)) and signed(opb) > 0 then
					V <= '1';
				else
					V <= '0';
				end if;result <= NULL;
			when "100011" => -- subc
				result <= NULL;
			when "100100" => -- mul
				result <= NULL;
			when "100101" => -- mulu
				result <= NULL;
			when "100110" => -- mulh
				result <= NULL;
			when "100111" => -- mulhu
				result <= NULL;
			when "101000" => -- or 
				result <= opa or opb;
			when "101001" => -- and
				result <= opa and opb;
			when "101010" => -- xor
				result <= opa xor opb;
			when "101011" => -- not
				result <= not opa;
			when "101100" => -- neg
--					if opa(15) = '1' then -- - to +
--						opa <= not (opa - 1);
--					else -- + to -
--						opa <= not (opa + 1);
--					end if;
				-- ich glaub auf opa schreiben is ka gute idee!
				-- ich glaub du willst da eher sowas wie:
				result <= not opa(15)&opa(14 downto 0);
				-- oda?
			when "101101" => -- asr --?
				-- fuer die ganzen shifts braucht ma kein tmp,
				-- wenn man & benutzt wie ich oben beim neg
				tmp(15) := opa(15);
				tmp(14 downto 0) := opa(15 downto 1);
				result <= tmp;
			when "101110" => -- lsl --?
				tmp(15 downto 1) := opa(14 downto 0);
				tmp(0) := '0';
				result <= tmp;
			when "101111" => -- lsr --?
				tmp(14 downto 0) := opa(15 downto 1);
				tmp(15) := '0';
				result <= tmp;
			when "110000" => -- lsli
-- geht ned
--					result <=  sll(opa, unsigned(opb(3 downto 0)));
-- auch ned... shifts broken
--					result <= std_logic_vector( unsigned(opa) sll unsigned(opb(3 downto 0)));
			when "110001" => -- lsri
--					result <= opa srl unsigned(opb(3 downto 0));
			when "110010" => -- scb
				if opb(4) = '1' then -- set bit
					-- auf opa schreiben is ka gute idee
--						opa(unsigned(opb(3 downto 0)) <= (others => '1'));
					result <= opa;
				else -- clear bit
					-- auf opa schreiben is ka gute idee
--						opa(unsigned(opb(3 downto 0)) <= (others => '1'));
					result <= opa;
				end if;
			when "110011" => -- roti
--				rol broken
--					if opb(4) = '0' then -- rotl
--						result <= opa rol unsigned(opb(3 downto 0));
--					else -- rotr
--						result <= opa ror unsigned(opb(3 downto 0));
--					end if;
--				when "110100" => -- cmpv
--					result <= x"0001" when V = '1' else x"0000";
			when "110101" => -- cmplt
--					result <= x"0001" when signed(opa) < signed(obb) else x"0000";
			when "110110" => -- cmpltu
--					result <= x"0001" when opa < opb else x"0000";
			when "110111" => -- cmplte
--					result <= x"0001" when signed(opa) <= signed(obb) else x"0000";
			when "111000" => -- cmplteu
				-- warum compiled das when scheissdrex ned da ueberall?
--					result <= x"0001" when (opa <= opb) else x"0000";
				if opa <= opb then
					result <= x"0001";
				else
					result <= x"0000";
				end if;
--				when "111001" => -- cmpe
--					result <= x"0001" when opa = opb else x"0000";
--				when "111010" => -- cmpei
--					tmp(15 downto 5) := (others => '0');
--					tmp(4 downto 0) := opb(4 downto 0);
--					result <= x"0001" when unsigned(opa) = unsigned(tmp) else x"0000";
			when "111011" => -- mov
				result <= opb;
			when "111100" => -- ld
				result <= x"0000";
			when "111101" => -- ldb
				result <= x"0000";
			when "111110" => -- st
				result <= x"0000";
			when "111111" => -- stb
				result <= x"0000";
			when "000000" => -- ldi
			when "000001" => -- ldi
			when "000010" => -- ldi
			when "000011" => -- ldi
			when "000100" => -- ldi
			when "000101" => -- ldi
			when "000110" => -- ldi
			when "000111" => -- ldi
				result(15 downto 8) <= (others => '0');
				result(7 downto 0) <= opb(7 downto 0);
			when "010000" => -- brezi
			when "010001" => -- brezi
			when "010010" => -- brezi
			when "010011" => -- brezi
				result <= x"0000";
			when "010100" => -- brnezi
			when "010101" => -- brnezi
			when "010110" => -- brnezi
			when "010111" => -- brnezi 
				result <= x"0000";
			when "011000" => -- addi
			when "011001" => -- addi
			when "011010" => -- addi
			when "011011" => -- addi
				result <= NULL;
			when "011100" => -- muli
			when "011101" => -- muli
			when "011110" => -- muli
			when "011111" => -- muli
				result <= NULL;
			when others =>
				result <= x"0000";
		end case;
	end process;
end sat1;

--todo:
--muli
--addi
--
