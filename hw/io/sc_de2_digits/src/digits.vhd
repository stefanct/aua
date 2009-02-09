library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.aua_types.all;

entity sc_de2_digits is
	port (
		clk     : in std_logic;
		reset	: in std_logic;

		-- SimpCon slave interface to IO ctrl
		address	: in sc_addr_t;
		wr_data	: in sc_data_t;
		rd		: in std_logic;
		wr		: in std_logic;
		rd_data	: out sc_data_t;
		rdy_cnt	: out sc_rdy_cnt_t;

		-- pins
		digit0_pins	: out std_logic_vector(6 downto 0);
		digit1_pins	: out std_logic_vector(6 downto 0);
		digit2_pins	: out std_logic_vector(6 downto 0);
		digit3_pins	: out std_logic_vector(6 downto 0);
		digit4_pins	: out std_logic_vector(6 downto 0);
		digit5_pins	: out std_logic_vector(6 downto 0)
	);
end digits;

architecture rtl of sc_de2_digits is

	signal digit0_nxt	: std_logic_vector(6 downto 0);
	signal digit1_nxt	: std_logic_vector(6 downto 0);
	signal digit2_nxt	: std_logic_vector(6 downto 0);
	signal digit3_nxt	: std_logic_vector(6 downto 0);
	signal digit4_nxt	: std_logic_vector(6 downto 0);
	signal digit5_nxt	: std_logic_vector(6 downto 0);
	
	signal digit0	: std_logic_vector(6 downto 0);
	signal digit1	: std_logic_vector(6 downto 0);
	signal digit2	: std_logic_vector(6 downto 0);
	signal digit3	: std_logic_vector(6 downto 0);
	signal digit4	: std_logic_vector(6 downto 0);
	signal digit5	: std_logic_vector(6 downto 0);

begin

	
	rd_data <= (others => '0');
	rdy_cnt <= (others => '0');	-- no wait states

	digit0_pins <= digit0;
	digit1_pins <= digit1;
	digit2_pins <= digit2;
	digit3_pins <= digit3;
	digit4_pins <= digit4;
	digit5_pins <= digit5;

	process(address, wr_data, wr, digit0, digit1, digit2, digit3, digit4, digit5)
	begin
		digit0_nxt <= digit0; 	    	
		digit1_nxt <= digit1; 	    	
		digit2_nxt <= digit2; 	    	
		digit3_nxt <= digit3; 	    	
		digit4_nxt <= digit4; 	    	
		digit5_nxt <= digit5; 	    	
		if wr = '1' then
			case address(3 downto 0) is
			    when x"0" => digit0_nxt <= wr_data(6 downto 0); 
			    when x"1" => digit1_nxt <= wr_data(6 downto 0); 
			    when x"2" => digit2_nxt <= wr_data(6 downto 0); 
			    when x"3" => digit3_nxt <= wr_data(6 downto 0); 
			    when x"4" => digit4_nxt <= wr_data(6 downto 0); 
			    when x"5" => digit5_nxt <= wr_data(6 downto 0);
			    when others => null;
			end case;
		end if;
	end process;

	process(clk, reset)
	begin

		if (reset='1') then
			digit0 <= (others => '1');
			digit1 <= (others => '1');
			digit2 <= (others => '1');
			digit3 <= (others => '1');
			digit4 <= (others => '1');
			digit5 <= (others => '1');

		elsif rising_edge(clk) then
		    digit0 <= digit0_nxt;
		    digit1 <= digit1_nxt;
		    digit2 <= digit2_nxt;
		    digit3 <= digit3_nxt;
		    digit4 <= digit4_nxt;
		    digit5 <= digit5_nxt;
		end if;

	end process;

end rtl;
