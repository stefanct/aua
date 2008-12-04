    library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

	use work.aua_types.all;

	entity reg is
		port (
			clock	: in std_logic;
			reset	: in std_logic;
			rega	: in reg_t;
			regb	: in reg_t;

			regr	: in reg_t;
			valr	: in word_t;

			vala	: out word_t;
			valb	: out word_t
		);
    end reg;

    architecture sat1 of reg is

--        constant CLK_FREQ : integer := 50000000; -- 20M for cycore; 50M for de2
--		type state_type		is (st_init, st_wait, st_rdst, st_rdcmd, st_flood_adr, st_flood);
--		signal state 		: state_type;
--		signal sc_adr	: std_logic_vector(0 downto 0);

	component ram is
	    port (
	    	clock		: in std_logic;
	    	data		: in std_logic_vector(15 downto 0);
	    	rdaddress_a	: in std_logic_vector(4 downto 0);
	    	rdaddress_b	: in std_logic_vector(4 downto 0);
	    	wraddress	: in std_logic_vector(4 downto 0);
	    	wren		: in std_logic;
	    	qa			: out std_logic_vector(15 downto 0);
	    	qb			: out std_logic_vector(15 downto 0)
	    	
	    );
	end component;

    begin
		vala <= (others => '0');
		valb <= (others => '0');
	
	process(reset)
	begin
	    null;
	end process;

	process(clock, reset)
	begin
	    if reset = '1' then
	    elsif rising_edge(clock) then
	    end if;
	end process;

    end sat1;