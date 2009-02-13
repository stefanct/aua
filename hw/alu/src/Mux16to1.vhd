library ieee;
use ieee.std_logic_1164.all;

entity Mux16to1 is
	port(	i01: in std_logic_vector(15 downto 0);
			i02: in std_logic_vector(15 downto 0);
			i03: in std_logic_vector(15 downto 0);
			i04: in std_logic_vector(15 downto 0);
			i05: in std_logic_vector(15 downto 0);
			i06: in std_logic_vector(15 downto 0);
			i07: in std_logic_vector(15 downto 0);
			i08: in std_logic_vector(15 downto 0);
			i09: in std_logic_vector(15 downto 0);
			i10: in std_logic_vector(15 downto 0);
			i11: in std_logic_vector(15 downto 0);
			i12: in std_logic_vector(15 downto 0);
			i13: in std_logic_vector(15 downto 0);
			i14: in std_logic_vector(15 downto 0);
			i15: in std_logic_vector(15 downto 0);
			i16: in std_logic_vector(15 downto 0);
			sel:	in std_logic_vector(3 downto 0);
			mux_out:	out std_logic_vector(15 downto 0)
		);
end entity;

architecture rtl of Mux16to1 is
	component Mux4to1 is
	port(	i01: in std_logic_vector(15 downto 0);
			i02: in std_logic_vector(15 downto 0);
			i03: in std_logic_vector(15 downto 0);
			i04: in std_logic_vector(15 downto 0);
			sel:	in std_logic_vector(1 downto 0);
			mux_out: out std_logic_vector(15 downto 0)
		);
	end component;
	
	signal mux_sel: std_logic_vector(1 downto 0);
	signal mux1_o:	std_logic_vector(15 downto 0);
	signal mux2_o:	std_logic_vector(15 downto 0);
	signal mux3_o:	std_logic_vector(15 downto 0);
	signal mux4_o:	std_logic_vector(15 downto 0);
	
begin
	mux1: Mux4to1 port map(i01, i02, i03, i04, mux_sel, mux1_o);
	mux2: Mux4to1 port map(i05, i06, i07, i08, mux_sel, mux2_o);
	mux3: Mux4to1 port map(i09, i10, i11, i12, mux_sel, mux3_o);
	mux4: Mux4to1 port map(i13, i14, i15, i16, mux_sel, mux4_o);
	
	process(sel, mux1_o, mux2_o, mux3_o, mux4_o)
	begin
		mux_sel <= sel(1 downto 0);
		case sel(3 downto 2) is
			when "00" => mux_out <= mux1_o;
			when "01" => mux_out <= mux2_o;
			when "10" => mux_out <= mux3_o;
			when "11" => mux_out <= mux4_o;
			when others => mux_out <= x"0000";
		end case;
	end process;
end rtl;