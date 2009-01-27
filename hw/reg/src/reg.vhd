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

begin
    cmp_ram_a: ram
		port map(clk, valr, rega, regr, '1', vala_ram);
	cmp_ram_b: ram
		port map(clk, valr, regb, regr, '1', valb_ram);
	
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
    
	
end rtl;
