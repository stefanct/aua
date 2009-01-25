library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.aua_types.all;

entity alu_tb is
end alu_tb;

architecture alu_test of alu_tb is
    
	component alu is
		port (
			clk     : in std_logic;
			reset	: in std_logic;
			opcode	: in opcode_t;
			opa		: in word_t;
			opb		: in word_t;
			result	: out word_t
		);
    end component;

	signal clk     : std_logic;
	signal reset	: std_logic;

	signal opa: word_t;
	signal opb: word_t;
	signal result: word_t;
	signal opcode: opcode_t;
	signal debug: word_t;
	begin
    
    alu1: alu port map(clk, reset, opcode, opa, opb, result);
    
    CLKGEN: process
    begin
        clk <= '1';
        wait for 5 ns;
        clk <= '0';
        wait for 5 ns;
    end process CLKGEN;
    
    TEST: process
    procedure icwait(cycles : natural) is
		begin
		  for i in 1 to cycles loop
			wait until clk = '0' and clk'event;
		  end loop;
		end;
    begin
--
			--reset <= '0';
			--icwait(5);
--
			icwait(1);
			
			-- ldi 
			opcode <= "000000";
			opb <= std_logic_vector(to_unsigned(12,word_t'length));
			icwait(1);
			assert result = x"0000" report "ldi: load not ignored - 1";
			icwait(5);
			
			opcode <= "000111";
			opb <= std_logic_vector(to_unsigned(12,word_t'length));
			icwait(1);
			assert result = x"0000" report "ldi: load not ignored - 2";
			icwait(5);
			
			--jmpl
			opcode <= "001101";
			opb <= std_logic_vector(to_unsigned(12,word_t'length));
			icwait(1);
			assert result = x"0000" report "jmpl: jmpl not ignored";
			icwait(5);
			
			--brez
			opcode <= "001110";
			opb <= std_logic_vector(to_unsigned(12,word_t'length));
			icwait(1);
			assert result = x"0000" report "brez: brez not ignored - 1";
			icwait(5);
			
			--brnez
			opcode <= "001111";
			opb <= std_logic_vector(to_unsigned(12,word_t'length));
			icwait(1);
			assert result = x"0000" report "brnez: brnez not ignored - 2";
			icwait(5);
			
			--brezi
			opcode <= "010000";
			opb <= std_logic_vector(to_unsigned(12,word_t'length));
			icwait(1);
			assert result = x"0000" report "brezi: brezi not ignored";
			icwait(5);
			
			--brnezi
			opcode <= "010100";
			opb <= std_logic_vector(to_unsigned(12,word_t'length));
			icwait(1);
			assert result = x"0000" report "brnezi: brnezi not ignored";
			icwait(5);
			
			--addi
			opcode <="011000";
			opa <= std_logic_vector(to_signed(12,word_t'length));
			opb <= std_logic_vector(to_signed(11,word_t'length));
			icwait(1);
			assert signed(result) = to_signed(23,word_t'length) report "addi: (+) + (+), (12 + 11 != 23)";   
			icwait(5);
			
			--addi
			opcode <="011001";
			opa <= std_logic_vector(to_signed(-12,word_t'length));
			opb <= std_logic_vector(to_signed(11,word_t'length));
			icwait(1);
			assert signed(result) = to_signed(-1,word_t'length) report "addi: (-) + (+), (-12 + 11 != -1)";
         icwait(5);
         
			--addi
			opcode <="011010";
			opa <= std_logic_vector(to_signed(12,word_t'length));
			opb <= std_logic_vector(to_signed(-11,word_t'length));
			icwait(1);
			assert signed(result) = to_signed(1,word_t'length) report "addi: (+) + (-), (12 + -11 != 1)";
			icwait(5);
			
			--addi
			opcode <="011011";
			opa <= std_logic_vector(to_signed(-12,word_t'length));
			opb <= std_logic_vector(to_signed(-11,word_t'length));
			icwait(1);
			assert signed(result) = to_signed(-23,word_t'length) report "addi: (-) + (-), (-12 + -11 != -23)";
			icwait(5);
			
			--muli
			opcode <= "011100";
			assert false report "muli: not implemented";
--			opa <= std_logic_vector(to_signed(12,word_t'length));
--			opb <= std_logic_vector(to_signed(11,word_t'length));
--			icwait(1);
--			assert signed(result) = to_signed(132,word_t'length) report "muli: (+) * (+), (12 * 11 != 132)";
--			icwait(5);
			
			--muli
			opcode <= "011100";
			assert false report "muli: not implemented";
--			opa <= std_logic_vector(to_signed(-12,word_t'length));
--			opb <= std_logic_vector(to_signed(11,word_t'length));
--			icwait(1);
--			assert signed(result) = to_signed(-132,word_t'length) report "muli: (-) * (+), (-12 * 11 != -132)";
--			icwait(5);
			
			--muli
			opcode <= "011100";
			assert false report "muli: not implemented";
--			opa <= std_logic_vector(to_signed(12,word_t'length));
--			opb <= std_logic_vector(to_signed(-11,word_t'length));
--			icwait(1);
--			assert signed(result) = to_signed(-132,word_t'length) report "muli: (+) * (-), (12 * -11 != -132)";
--			icwait(5);
			
			--muli
			opcode <= "011100";
			assert false report "muli: not implemented";
--			opa <= std_logic_vector(to_signed(-12,word_t'length));
--			opb <= std_logic_vector(to_signed(-11,word_t'length));
--			icwait(1);
--			assert signed(result) = to_signed(132,word_t'length) report "muli: (-) * (-), (-12 * -11 != 132)";
--			icwait(5);
			
			--add
			opcode <="100000";
			opa <= std_logic_vector(to_signed(12,word_t'length));
			opb <= std_logic_vector(to_signed(11,word_t'length));
			icwait(1);
			assert signed(result) = to_signed(23,word_t'length) report "add: (+) + (+), (12 + 11 != 23)";
			icwait(5);
			
			--add
			opcode <="100000";
			opa <= std_logic_vector(to_signed(-12,word_t'length));
			opb <= std_logic_vector(to_signed(11,word_t'length));
			icwait(1);
			assert signed(result) = to_signed(-1,word_t'length) report "add: (-) + (+), (-12 + 11 != -1)";
         icwait(5);
			
			--add
			opcode <="100000";
			opa <= std_logic_vector(to_signed(12,word_t'length));
			opb <= std_logic_vector(to_signed(-11,word_t'length));
			icwait(1);
			assert signed(result) = to_signed(1,word_t'length) report "add: (+) + (-), (12 + -11 != 1)";
			icwait(5);
			
			--add
			opcode <="100000";
			opa <= std_logic_vector(to_signed(-12,word_t'length));
			opb <= std_logic_vector(to_signed(-11,word_t'length));
			icwait(1);
			assert signed(result) = to_signed(-23,word_t'length) report "add: (-) + (-), (-12 + -11 != -23)";
			icwait(5);
			
			--addc
			opcode <= "100000";
			opa <= std_logic_vector(to_unsigned(2**16-1,word_t'length));
			opb <= std_logic_vector(to_unsigned(2,word_t'length));
			icwait(1);
			assert unsigned(result) = to_unsigned(1,word_t'length) report "add: (+) + (+), (FFFF + 2 != 0001,c=1)";
			opcode <= "100001";
			opa <= std_logic_vector(to_unsigned(0,word_t'length));
			opb <= std_logic_vector(to_unsigned(2,word_t'length));
			icwait(1);
			assert unsigned(result) = to_unsigned(3,word_t'length) report "addc: (+) + (+), (0 + 2 + c(=1) != 3)";
         icwait(5);
			
			--sub
			opcode <="100010";
			opa <= std_logic_vector(to_signed(12,word_t'length));
			opb <= std_logic_vector(to_signed(11,word_t'length));
			icwait(1);
			assert signed(result) = to_signed(1,word_t'length) report "sub: (+) - (+), (12 - 11 != 1)";
			icwait(5);
			
			--sub
			opcode <="100010";
			opa <= std_logic_vector(to_signed(-12,word_t'length));
			opb <= std_logic_vector(to_signed(11,word_t'length));
			icwait(1);
			assert signed(result) = to_signed(-23,word_t'length) report "sub: (-) - (+), (-12 - 11 != -23)";
			icwait(5);
			
			--sub
			opcode <="100010";
			opa <= std_logic_vector(to_signed(12,word_t'length));
			opb <= std_logic_vector(to_signed(-11,word_t'length));
			icwait(1);
			assert signed(result) = to_signed(23,word_t'length) report "sub: (+) - (-), (12 - -11 != 23)";
         icwait(5);

			--sub
			opcode <="100010";
			opa <= std_logic_vector(to_signed(-12,word_t'length));
			opb <= std_logic_vector(to_signed(-11,word_t'length));
			icwait(1);
			assert signed(result) = to_signed(-1,word_t'length) report "sub: (-) - (-), (-12 - -11 != -1)";
			icwait(5);
			
			--subc
			--opcode <= "100010";
			--opa <= std_logic_vector(to_unsigned(1,word_t'length));
			--opb <= std_logic_vector(to_unsigned(3,word_t'length));
			--assert std_logic_vector(to_unsigned(result,word_t'length)) /= to_signed(-2) report "add: (+) - (+), (1 - 3 != -2,c=1)"
			--opcode <= "100011";
			--raga <= std_logic_vector(to_unsigned(0,word_t'length));
			--opb <= std_logic_vector(to_unsigned(2,word_t'length));
			--assert std_logic_vector(to_unsigned(result,word_t'length)) /= to_signed(3) report "addi: (+) + (+), (0 - 2 - c(=1) != 3)"
			
			--mul
			opcode <= "100100";
			assert false report "mul: not implemented";			
			--mulu
			opcode <= "100101";
			assert false report "mulu: not implemented";
			--mulh
			opcode <= "100110";
			assert false report "mulhu: not implemented";
			--mulhu
			opcode <= "100111";
			assert false report "mulhu: not implemented";
			
			--or
			opcode <= "101000";
			opa <= x"FF00";
			opb <= x"00FF";
			icwait(1);
			assert result = x"FFFF" report "or: FF00 or 00FF != FFFF";
			icwait(5);
			
			--and
			opcode <= "101001";
			opa <= x"FF00";
			opb <= x"00FF";
			icwait(1);
			assert result = x"0000" report "and: FF00 and 00FF != 0000";
			icwait(5);
			
			--xor
			opcode <= "101010";
			opa <= x"F0F0";
			opb <= x"FF00";
			icwait(1);
			assert result = x"0FF0" report "or: F0F0 or FF00 != 0FF0";
			icwait(5);
			
			--not
			opcode <= "101011";
			opb <= x"F0F0";
			icwait(1);
			assert result = x"0F0F" report "not: not F0F0 != 0F0F";
			icwait(5);
			
			--neg
			opcode <= "101100";
			opb <= x"00FF";
			icwait(1);
			debug <= result;
			assert result = x"FF01" report "neg: (+) -> (-), 255 !-> -255";
			icwait(5);
			
			--neg
			opcode <= "101100";
			opb <= x"FF01";
			icwait(1);
			debug <= result;
			assert result = x"00FF" report "neg: (-) -> (+), -255 !-> +255";
			icwait(5);
			
			--asr
			opcode <= "101101";
			opb <= x"9999";
			icwait(1);
			assert result = x"CCCC" report "asr: 1 shift, 1001100110011001 !=> 1100110011001100";
			icwait(5);
			
			--asr
			opcode <= "101101";
			opb <= x"6666";
			icwait(1);
			assert result = x"3333" report "asr: 0 shift, 0110011001100110 !=> 0011001100110011";
			icwait(5);
			
			--lsl
			opcode <= "101110";
			opb <= x"F0F0";
			icwait(1);
			debug <= result;
			assert result = x"E1E0" report "lsl: 0 shift, 1111000011110000 !=> 1110000111100000";  
			icwait(5);
			
			--lsr
			opcode <= "101111";
			opb <= x"F0F0";
			icwait(1);
			assert result = x"7878" report "lsr: 0 shift, 1111000011110000 !=> 0111100001111000";
			icwait(5);
			
			--lsli
			opcode <= "110000";
			opa <= x"0001";
			opb <= std_logic_vector(to_unsigned(3,word_t'length));
			icwait(1);
			assert result = x"0008" report "lsli: shift right about 3, 0001 !=> 0008";   
			icwait(5);
			
			--lsri
			opcode <= "110001";
			opa <= x"8000";
			opb <= std_logic_vector(to_unsigned(3,word_t'length));
			icwait(1);
			assert result = x"1000" report "asri: shift right about 3, 8000 !=> 1000";
			icwait(5);
			
			--scb
			opcode <= "110010";
			opa <= x"FFFF";
			opb <= std_logic_vector(to_unsigned(0,word_t'length));
			icwait(1);
			debug <= result;
			assert result = x"FFFE" report "scb: clear bit 0 error"; 
			icwait(5);
			
			--scb
			opcode <= "110010";
			opa <= x"FFFE";
			opb <= std_logic_vector(to_unsigned(16,word_t'length));
			debug <= result;
			icwait(1);
			assert result = x"FFFF" report "scb: set bit 0 error";
			icwait(5);
			
			--roti -- 0 = links
			opcode <= "110011";
			opa <= x"0001";
			opb <= std_logic_vector(to_unsigned(17,word_t'length));
			icwait(1);
			assert result = x"8000" report "roti: roll 1 bit right, 0001 !=> 8000"; 
			icwait(5);
			
			--roti 
			opcode <= "110011";
			opa <= x"8000";
			opb <= std_logic_vector(to_unsigned(1,word_t'length));
			icwait(1);
			assert result = x"0001" report "roti: roll 1 bit left, 0001 !=> 8000";
			icwait(5);
			
			--cmpv out of isa
			--opcode <= "110100"
			
			--cmplt
			opcode <= "110101";
         opa <= std_logic_vector(to_signed(3,word_t'length));
			opb <= std_logic_vector(to_signed(3,word_t'length));
			icwait(1);
			assert result = x"0000" report "cmplt: 3 < 3";
			icwait(5);
			
			--cmplt
			opcode <= "110101";
			opa <= std_logic_vector(to_signed(4,word_t'length));
			opb <= std_logic_vector(to_signed(3,word_t'length));
			icwait(1);
			assert result = x"0000" report "cmplt: 4 !< 3";
			icwait(5);
			
			--cmplt
			opcode <= "110101";
			opa <= std_logic_vector(to_signed(3,word_t'length));
			opb <= std_logic_vector(to_signed(4,word_t'length));
			icwait(1);
			assert result = x"0001" report "cmplt: 3 !< 4";
			icwait(5);
			
			--cmplt
			opcode <= "110101";
			opa <= std_logic_vector(to_signed(-3,word_t'length));
			opb <= std_logic_vector(to_signed(-4,word_t'length));
			icwait(1);
			assert result = x"0000" report "cmplt: -3 < -4";
			icwait(5);
			
			--cmplt
			opcode <= "110101";
			opa <= std_logic_vector(to_signed(-4,word_t'length));
			opb <= std_logic_vector(to_signed(-3,word_t'length));
			icwait(1);
			assert result = x"0001" report "cmplt: -4 !< -3";
			icwait(5);
			
			--cmpltu
			opcode <= "110110";
			opa <= std_logic_vector(to_unsigned(3,word_t'length));
			opb <= std_logic_vector(to_unsigned(4,word_t'length));
			icwait(1);
			assert result = x"0001" report "cmplt: 3 !< 4";
			icwait(5);
			
			--cmpltu
			opcode <= "110110";
			opa <= std_logic_vector(to_unsigned(4,word_t'length));
			opb <= std_logic_vector(to_unsigned(3,word_t'length));
			icwait(1);
			assert result = x"0000" report "cmpltu: 4 < 3";
			icwait(5);
			
			--cmpltu
			opcode <= "110110";
			opa <= std_logic_vector(to_unsigned(3,word_t'length));
			opb <= std_logic_vector(to_unsigned(3,word_t'length));
			icwait(1);
			assert result = x"0000" report "cmpltu: 3 < 3";
			icwait(5);
			
			--cmplte
			opcode <= "110111";
			opa <= std_logic_vector(to_signed(3,word_t'length));
			opb <= std_logic_vector(to_signed(3,word_t'length));
			icwait(1);
			assert result = x"0001" report "cmplte: 3 !<= 3";
			icwait(5);
			
			--cmplte
			opcode <= "110111";
			opa <= std_logic_vector(to_signed(3,word_t'length));
			opb <= std_logic_vector(to_signed(4,word_t'length));
			icwait(1);
			assert result = x"0001" report "cmplte: 3 !<= 4";
			icwait(5);
			
			--cmplte
			opcode <= "110111";
			opa <= std_logic_vector(to_signed(4,word_t'length));
			opb <= std_logic_vector(to_signed(3,word_t'length));
			icwait(1);
			assert result = x"0000" report "cmplte: 4 <= 3";
			icwait(5);
			
			--cmplte
			opcode <= "110111";
			opa <= std_logic_vector(to_signed(-3,word_t'length));
			opb <= std_logic_vector(to_signed(4,word_t'length));
			icwait(1);
			assert result = x"0001" report "cmplte: -3 !<= 4";
			icwait(5);
			
			--cmplteu
			opcode <= "111000";
			opa <= std_logic_vector(to_unsigned(3,word_t'length));
			opb <= std_logic_vector(to_unsigned(4,word_t'length));
			icwait(1);
			assert result = x"0001" report "cmplteu: 3 !<= 4";
			icwait(5);
			
			--cmplteu
			opcode <= "111000";
			opa <= std_logic_vector(to_unsigned(4,word_t'length));
			opb <= std_logic_vector(to_unsigned(3,word_t'length));
			icwait(1);
			assert result = x"0000" report "cmplteu: 4 <= 3";
			icwait(5);
			
			--cmpe
			opcode <= "111001";
			opa <= std_logic_vector(to_signed(3,word_t'length));
			opb <= std_logic_vector(to_signed(3,word_t'length));
			icwait(1);
			assert result = x"0001" report "cmpe: 3 != 3";
			icwait(5);
			
			--cmpe
			opcode <= "111001";
			opa <= std_logic_vector(to_signed(3,word_t'length));
			opb <= std_logic_vector(to_signed(4,word_t'length));
			icwait(1);
			assert result = x"0000" report "cmpe: 3 = 4";
			icwait(5);
			
			--cmpe
			opcode <= "111001";
			opa <= std_logic_vector(to_signed(3,word_t'length));
			opb <= std_logic_vector(to_signed(-4,word_t'length));
			icwait(1);
			assert result = x"0000" report "cmpe: 3 = -4";
			icwait(5);
			
			--cmpei
			opcode <= "111010";
			opa <= std_logic_vector(to_signed(3,word_t'length));
			opb <= std_logic_vector(to_signed(3,word_t'length));
			icwait(1);
			assert result = x"0001" report "cmpei: 3 != 3";
			icwait(5);
			
			--cmpei
			opcode <= "111010";
			opa <= std_logic_vector(to_signed(3,word_t'length));
			opb <= std_logic_vector(to_signed(4,word_t'length));
			icwait(1);
			assert result = x"0000" report "cmpei: 3 = 4";
			icwait(5);
			
			--cmpei
			opcode <= "111010";
			opa <= std_logic_vector(to_signed(3,word_t'length));
			opb <= std_logic_vector(to_signed(-4,word_t'length));
			icwait(1);
			assert result = x"0000" report "cmpei: 3 = -4";
			icwait(5);
			
			--mov
			opcode <= "111011";
			opb <= x"FFFF";
			icwait(1);
			assert result = x"FFFF" report "mov: FFFF !=> FFFF";
			icwait(5);
			
			--ld
			opcode <= "111100";
			opb <= x"FFFF";
			icwait(1);
			assert result = x"0000" report "ld: load not ignored";
			icwait(5);
			
			--ldb
			opcode <= "111101";
			opb <= x"FFFF";
			icwait(1);
			assert result = x"0000" report "ld: load not ignored";
			icwait(5);
			
			--st
			opcode <= "111110";
			opb <= x"FFFF";
			icwait(1);
			assert result = x"0000" report "st: store not ignored";
			icwait(5);
			
			--stb
			opcode <= "111111";
			opb <= x"FFFF";
			icwait(1);
			assert result = x"0000" report "st: store not ignored";
         
         assert false report "sim finish" SEVERITY failure;
    end process TEST;
    
end alu_test;