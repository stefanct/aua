library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
-- used for address width calculation
use ieee.math_real.log2;
use ieee.math_real.ceil;

package aua_types is

--	type io_devs is array(natural range <>) of component;
	subtype word_t is std_logic_vector(15 downto 0);
	subtype opcode_t is std_logic_vector(5 downto 0);
	subtype reg_t is std_logic_vector(4 downto 0);
	subtype pc_t is unsigned(15 downto 0);

	constant RAM_ADDR_SIZE : integer := 14;

	constant SC_ADDR_SIZE : integer := 16;
	constant SC_DATA_SIZE : integer := 32;
	constant RDY_CNT_SIZE : integer := 2;
	constant SLAVE_CNT : integer := 4;
	-- number of bits needed to address all slaves (2**SC_ADDR_BITS >= SLAVE_CNT)
	constant SC_ADDR_BITS : integer := integer(ceil(log2(real(SLAVE_CNT))));
	-- number of bits that can be used inside the slave
	-- constant SLAVE_ADDR_BITS : integer := 4;

	type sc_out_t is record
		address		: std_logic_vector(SC_ADDR_SIZE-1 downto 0);
		wr_data		: std_logic_vector(SC_DATA_SIZE-1 downto 0);
		rd			: std_logic;
		wr			: std_logic;
	end record;

	type sc_in_t is record
		rd_data		: std_logic_vector(SC_DATA_SIZE-1 downto 0);
		rdy_cnt		: unsigned(RDY_CNT_SIZE-1 downto 0);
	end record;
	type sc_in_at is array (0 to SLAVE_CNT-1) of sc_in_t;

	subtype sc_addr_t is std_logic_vector(SC_ADDR_SIZE-1 downto 0);
	subtype sc_data_t is std_logic_vector(SC_DATA_SIZE-1 downto 0);

	subtype sc_rdy_cnt_t is unsigned(1 downto 0);
	type sc_rdy_cnt_at is array(0 to SLAVE_CNT-1) of sc_rdy_cnt_t;


end aua_types;

--~ package body aua_types is
--~ 
--~ end aua_types;
