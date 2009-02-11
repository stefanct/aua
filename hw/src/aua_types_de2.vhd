library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
-- used for address width calculation
use ieee.math_real.log2;
use ieee.math_real.ceil;

package aua_types is
	constant ADDR_SIZE		: natural := 16;

	subtype word_t is std_logic_vector(ADDR_SIZE-1 downto 0);
	subtype pc_t is unsigned(ADDR_SIZE-1 downto 0);
	subtype opcode_t is std_logic_vector(5 downto 0);
	subtype reg_t is std_logic_vector(4 downto 0);

--

	constant CLK_FREQ		: natural :=  70000000; -- main clock frequency
	constant SRAM_RD_FREQ	: natural :=  50000000; -- ram clock when reading
	constant SRAM_WR_FREQ	: natural :=  50000000; -- ram clock when writing
	constant UART_RATE		: natural := 115200; -- uart baud rate

	constant RST_VECTOR		: pc_t := x"8000";

	constant RAM_ADDR_SIZE	: natural := 14;
	constant SC_SLAVE_CNT	: natural := 4; -- count of simpcon slaves
	constant SC_ADDR_SIZE	: natural := ADDR_SIZE;
	constant SC_DATA_SIZE	: natural := 32;
	constant SC_RDY_CNT_SIZE : natural := 2;

--

	-- number of bits needed to address all slaves (2**SC_ADDR_BITS >= SLAVE_CNT)
	constant SC_ADDR_BITS : integer := integer(ceil(log2(real(SC_SLAVE_CNT))));

	type sc_out_t is record
		address		: std_logic_vector(SC_ADDR_SIZE-1 downto 0);
		wr_data		: std_logic_vector(SC_DATA_SIZE-1 downto 0);
		rd			: std_logic;
		wr			: std_logic;
	end record;
	type sc_out_at is array (0 to SC_SLAVE_CNT-1) of sc_out_t;

	subtype sc_rdy_cnt_t is unsigned(SC_RDY_CNT_SIZE-1 downto 0);

	type sc_in_t is record
		rd_data		: std_logic_vector(SC_DATA_SIZE-1 downto 0);
		rdy_cnt		: sc_rdy_cnt_t;
	end record;
	type sc_in_at is array (0 to SC_SLAVE_CNT-1) of sc_in_t;

	subtype sc_addr_t is std_logic_vector(SC_ADDR_SIZE-1 downto 0);
	subtype sc_data_t is std_logic_vector(SC_DATA_SIZE-1 downto 0);


	function max (L, R: real) return real;

end aua_types;

-- package body for aua on DE2
package body aua_types is
   	function max (L, R: real) return real IS
	begin
	    if L > R then
	        return L;
	    else
	        return R;
	    end if;
	end function max;
end aua_types;
