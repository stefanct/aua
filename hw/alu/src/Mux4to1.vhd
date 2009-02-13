library ieee;
use ieee.std_logic_1164.all;

entity Mux4to1 is 
	port(	i01: in std_logic_vector(15 downto 0);
			i02: in std_logic_vector(15 downto 0);
			i03: in std_logic_vector(15 downto 0);
			i04: in std_logic_vector(15 downto 0);
			sel:	in std_logic_vector(1 downto 0);
			mux_out: out std_logic_vector(15 downto 0)
		);
end Mux4to1;

architecture rtl of Mux4to1 is
begin
	process(sel, i01, i02, i03, i04)
	begin
		case sel is
			when "00" => mux_out <= i01;
			when "01" => mux_out <= i02;
			when "10" => mux_out <= i03;
			when "11" => mux_out <= i04;
			when others => mux_out <= x"0000";
		end case;
	end process;
end rtl;