library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.aua_types.all;

entity reg is
	port (
		clk			: in std_logic;
		reset		: in std_logic;
		async_rega	: in reg_t;
		async_regb	: in reg_t;
		rega		: in reg_t;
		regb		: in reg_t;

		async_regr	: in reg_t;
		async_valr	: in word_t;

		vala		: out word_t;
		valb		: out word_t
	);
end reg;

architecture rtl of reg is

component ram is
	port (
		clock		: in std_logic;
		data		: in word_t;
		rdaddress	: in reg_t;
		wraddress	: in reg_t;
		wren		: in std_logic;
		q			: out word_t
		
	);
end component;
	
	signal vala_ram	: word_t;
	signal valb_ram	: word_t;
	signal regr	: reg_t;
	signal valr	: word_t;

begin
    cmp_ram_a: ram
		port map(clk, async_valr, async_rega, async_regr, '1', vala_ram);
	cmp_ram_b: ram
		port map(clk, async_valr, async_regb, async_regr, '1', valb_ram);
	
	process(rega, regb, regr, valr, vala_ram, valb_ram)
	begin
      if(rega = regr) then
          vala <= valr;
      else
          vala <= vala_ram;
      end if;
      
      if(regb = regr) then
          valb <= valr;
      else
          valb <= valb_ram;
      end if;
    end process;
    
	sync: process (clk, reset)
	begin
		if reset = '1' then
			valr <= (others => '0');
			regr <= (others => '0');
		elsif rising_edge(clk) then
			valr <= async_valr;
			regr <= async_regr;
		end if;
	end process;
	
end rtl;
