library ieee;
use ieee.std_logic_1164.all;

entity Mux32to1 is
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
			i17: in std_logic_vector(15 downto 0);
			i18: in std_logic_vector(15 downto 0);
			i19: in std_logic_vector(15 downto 0);
			i20: in std_logic_vector(15 downto 0);
			i21: in std_logic_vector(15 downto 0);
			i22: in std_logic_vector(15 downto 0);
			i23: in std_logic_vector(15 downto 0);
			i24: in std_logic_vector(15 downto 0);
			i25: in std_logic_vector(15 downto 0);
			i26: in std_logic_vector(15 downto 0);
			i27: in std_logic_vector(15 downto 0);
			i28: in std_logic_vector(15 downto 0);
			i29: in std_logic_vector(15 downto 0);
			i30: in std_logic_vector(15 downto 0);
			i31: in std_logic_vector(15 downto 0);
			i32: in std_logic_vector(15 downto 0);
			sel: in std_logic_vector(4 downto 0);
			mux_out: out std_logic_vector(15 downto 0)
		);
end entity;

architecture rtl of Mux32to1 is

component Mux16to1 is
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
end component;

signal mux_sel: std_logic_vector(3 downto 0);
signal mux1_o:	std_logic_vector(15 downto 0);
signal mux2_o:	std_logic_vector(15 downto 0);

begin

	mux1: Mux16to1 port map(i01,i02,i03,i04,i05,i06,i07,i08,i09,i10,i11,i12,i13,i14,i15,i16,mux_sel,mux1_o);
	mux2: Mux16to1 port map(i17,i18,i19,i20,i21,i22,i23,i24,i25,i26,i27,i28,i29,i30,i31,i32,mux_sel,mux2_o);
	
	process(sel, mux1_o, mux2_o)
	begin
		mux_sel <= sel(3 downto 0);
		if sel(4) = '0' then
			mux_out <= mux1_o;
		else
			mux_out <= mux2_o;
		end if;
	end process;
end architecture;