library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.aua_types.all;

entity sc_test_slave is
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
end sc_test_slave;

architecture rtl of sc_test_slave is

	signal cycle_cnt, cycle_cnt_nxt	: unsigned(3 downto 0);
	signal ready, ready_nxt			: unsigned(3 downto 0);
	signal reg, reg_nxt				: sc_data_t;
	signal sc_out, sc_out_nxt					: sc_data_t;

	type state_type is (st_done, st_wait);
	signal state		: state_type;
	signal state_nxt	: state_type;

begin

	rd_data <= sc_out;

nxt: process(reset, state, cycle_cnt, reg, wr_data, address, wr, rd, ready, sc_out)
begin
	cycle_cnt_nxt <= cycle_cnt;
	reg_nxt <= reg;
	sc_out_nxt <= sc_out;
	rdy_cnt <= (others => '0');
	ready_nxt <= ready;
	state_nxt <= st_done;
	
	if state=st_done then
		case address is
			when sc_base_addr =>
				if(wr='1') then
					cycle_cnt_nxt <= unsigned(wr_data(3 downto 0));
				end if;
				if rd='1' then
					sc_out_nxt <= (sc_out_nxt'length-1 downto cycle_cnt'length => '0')&std_logic_vector(cycle_cnt);
				end if;
			when sc_addr_t(unsigned(sc_base_addr)+1) =>
				if(wr='1') then
					reg_nxt <= wr_data;
					state_nxt <= st_wait;
					ready_nxt <= cycle_cnt;
				end if;
				if(rd='1') then
					sc_out_nxt <= reg;
					state_nxt <= st_wait;
					ready_nxt <= cycle_cnt;
				end if;
			when others =>
				null;
		end case;
	else
		ready_nxt <= ready-1;
		sc_out_nxt <= reg;
		if ready > 3 then
			rdy_cnt <= "11";
		else
			rdy_cnt <= ready(1 downto 0);
		end if;
		if ready /= 0 then
			state_nxt <= st_wait;
		end if;
	end if;
end process;

sync: process(clk, reset)
begin
	if (reset='1') then
		sc_out <= (others => '0');
		cycle_cnt <= (others => '0');
		reg <= (others => '0');
		ready <= (others => '0');
		state <= st_done;
	elsif rising_edge(clk) then
		sc_out <= sc_out_nxt;
		cycle_cnt <= cycle_cnt_nxt;
		reg <= reg_nxt;
		ready <= ready_nxt;
		state <= state_nxt;
	end if;
end process;

end rtl;
