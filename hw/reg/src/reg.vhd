library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.aua_types.all;

entity reg is
	port (
		clk	: in std_logic;
		reset	: in std_logic;
		rega	: in reg_t;
		regb	: in reg_t;

		regr	: in reg_t;
		valr	: in word_t;

		vala	: out word_t;
		valb	: out word_t
	);
end reg;

architecture rtl of reg is

--        constant CLK_FREQ : integer := 50000000; -- 20M for cycore; 50M for de2
--		type state_type		is (st_init, st_wait, st_rdst, st_rdcmd, st_flood_adr, st_flood);
--		signal state 		: state_type;
--		signal sc_adr	: std_logic_vector(0 downto 0);

component ram is
	port (
		address_a	: in reg_t;
		address_b	: in reg_t;
		clock		: in std_logic;
		data_a		: in word_t;
		data_b		: in word_t;
		wren_a		: in std_logic;
		wren_b		: in std_logic;
		q_a			: out word_t;
		q_b			: out word_t
		
	);
end component;

    signal scheiss	: word_t;
    signal vhdl	: word_t;

begin
    
    
	cmp_ram_a: ram
		port map(regr, rega, clk, valr, (others=>'0'), '1', '0', vala, scheiss);
	cmp_ram_b: ram
		port map(regr, regb, clk, valr, (others=>'0'), '1', '0', valb, vhdl);
	--cmp_ram_a: ram
	--	port map(clk, valr, rega, regr, '1', vala);
	--cmp_ram_b: ram
	--	port map(clk, valr, regb, regr, '1', valb);
	
end rtl;
