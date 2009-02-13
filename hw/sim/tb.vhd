library ieee;
use ieee.std_logic_1164.all;
use work.aua_types.all;

entity aua_tb is

end aua_tb;

architecture aua_test of aua_tb is
    component aua
		port (
			clk_in		: in std_logic;
			reset_pin	: in std_logic;
			switch_pins	: in std_logic_vector(15 downto 0);
			led_pins	: out std_logic_vector(15 downto 0);
			digit0_pins	: out std_logic_vector(6 downto 0);
			digit1_pins	: out std_logic_vector(6 downto 0);
			digit2_pins	: out std_logic_vector(6 downto 0);
			digit3_pins	: out std_logic_vector(6 downto 0);
			digit4_pins	: out std_logic_vector(6 downto 0);
			digit5_pins	: out std_logic_vector(6 downto 0);
			sram_addr	: out std_logic_vector(RAM_ADDR_SIZE-1  downto 0);
			sram_dq		: inout word_t;
			sram_we		: out std_logic;
		--	sram_oe		: out std_logic;
			sram_ub		: out std_logic;
			sram_lb		: out std_logic;
		--	sram_ce		: out std_logic
			txd			: out std_logic;
			rxd			: in std_logic
			--~ ncts		: in std_logic;
			--~ nrts		: out std_logic

		);
    end component;
    
	signal clk			: std_logic;
	signal reset_pin	: std_logic;
	signal switch_pins	: std_logic_vector(15 downto 0);
	signal led_pins		: std_logic_vector(15 downto 0);
	signal digit0_pins	: std_logic_vector(6 downto 0);
	signal digit1_pins	: std_logic_vector(6 downto 0);
	signal digit2_pins	: std_logic_vector(6 downto 0);
	signal digit3_pins	: std_logic_vector(6 downto 0);
	signal digit4_pins	: std_logic_vector(6 downto 0);
	signal digit5_pins	: std_logic_vector(6 downto 0);
	signal sram_addr	: std_logic_vector(RAM_ADDR_SIZE-1 downto 0);
	signal sram_dq		: word_t;
	signal sram_we		: std_logic;
	signal sram_ub		: std_logic;
	signal sram_lb		: std_logic;
	signal txd		: std_logic;
	signal rxd		: std_logic;
begin
    
    aua1: configuration work.aua_cache
    port map (
		clk_in => clk,
		reset_pin => reset_pin,
		switch_pins => switch_pins,
		led_pins => led_pins,
		digit0_pins => digit0_pins,
		digit1_pins => digit1_pins,
		digit2_pins => digit2_pins,
		digit3_pins => digit3_pins,
		digit4_pins => digit4_pins,
		digit5_pins => digit5_pins,
		sram_addr => sram_addr,
		sram_dq => sram_dq,
		sram_we => sram_we,
		sram_ub => sram_ub,
		sram_lb => sram_lb,
		txd => txd,
		rxd => rxd
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
        reset_pin <= '0';
        switch_pins <= x"DEAD";
        sram_dq <= (others => '0');
        rxd <= '0';
        
        icwait(2);
        reset_pin <= '1';
        
        icwait(40);
        
        assert false report "sim finish" SEVERITY failure;
                
    end process TEST;
    
end aua_test;
