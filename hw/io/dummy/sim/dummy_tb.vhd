library ieee;
use ieee.std_logic_1164.all;
use work.aua_types.all;

entity dummy_tb is

end dummy_tb;

architecture dummy_test of dummy_tb is
    component sc_test_slave
		generic(
			sc_base_addr	: sc_addr_t -- base = cycle setup register, base+1 = rd/wr test register
		);
		port (
			clk     : in std_logic;
			reset	: in std_logic;

			-- SimpCon slave interface to IO ctrl
			address	: in sc_addr_t;
			wr_data	: in sc_data_t;
			rd		: in std_logic;
			wr		: in std_logic;
			rd_data	: out sc_data_t;
			rdy_cnt	: out sc_rdy_cnt_t
		);
    end component;
    
	signal clk		: std_logic;
	signal reset	: std_logic;
	signal address	: sc_addr_t;
	signal wr_data	: sc_data_t;
	signal rd		: std_logic;
	signal wr		: std_logic;
	signal rd_data	: sc_data_t;
	signal rdy_cnt	: sc_rdy_cnt_t;
begin
    
    sc_test_slave1: sc_test_slave
    generic map ( x"FFFE"
    )
    port map (
		clk,
		reset,
		address,
		wr_data,
		rd,
		wr,
		rd_data,
		rdy_cnt
	);
    
    CLKGEN: process
    begin
        clk <= '1';
        wait for 10 ns;
        clk <= '0';
        wait for 10 ns;
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
        address <= x"DEAD";
        wr_data <= (others => '0');
        wr <= '0';
        rd <= '0';
        
        icwait(2);
        reset <= '0';

        wr_data <= x"12345678";
        wr <= '1';
        rd <= '1';
        icwait(2);
        
        rd <= '0';
        address <= x"FFFE";
        icwait(1);

        wr <= '0';
        wr_data <= x"12345678";
        address <= x"FFFF";
        wr <= '1';
        icwait(1);

        wr <= '0';
        icwait(10);
        wr_data <= x"00000000";
        rd <= '1';
        icwait(1);

        rd <= '0';
        icwait(9);
        address <= x"FFFE";
        rd <= '1';
        icwait(1);

        rd <= '0';
        icwait(3);
        
        assert false report "sim finish" SEVERITY failure;
                
    end process TEST;
    
end dummy_test;
