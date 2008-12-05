library ieee;
use ieee.std_logic_1164.all;

use work.aua_types.all;
entity if_tb is

end if_tb;

architecture if_test of if_tb is
    
	component ent_if is
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

			-- mmu
			instr_addr	: out word_t;
			instr_data	: in word_t

		);
    end component;

    
	signal clk     : std_logic;
	signal reset	: std_logic;

	-- pipeline register outputs
	signal opcode	: opcode_t;
	signal dest	: reg_t;
	signal pc_out	: word_t;
	signal rega	: reg_t;
	signal regb	: reg_t;
	signal imm		: std_logic_vector(7 downto 0);

	signal async_rega	: reg_t;
	signal async_regb	: reg_t;
	-- branches (from ID)
	signal pc_in		: word_t;
	signal branch		: std_logic;

	-- mmu
	signal instr_addr	: word_t;
	signal instr_data	: word_t;
    
	begin
    
    if1: ent_if
    	port map(clk, reset, opcode, dest, pc_out, rega, regb, imm, async_rega, async_regb, pc_in, branch, instr_addr, instr_data);

    
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
           reset <= '1';
		   pc_in <= "1111111111111111";
		   branch <= '0';
		   instr_data <= "1100110010101010";
           icwait(2);
--
			reset <= '0';
			icwait(1);
--
			branch <= '1';
			icwait(1);
--
			branch <= '0';
			instr_data <= "0000110010101010";
			icwait(100);
--

    end process TEST;
    
end if_test;