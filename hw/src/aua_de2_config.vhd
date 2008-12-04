library ieee;
use ieee.std_logic_1164.all;
use work.aua_types.all;

package aua_config is

--	constants for 50MHz input clock
--	constant clk_freq : integer := 90000000;
--	constant pll_mult : natural := 9;
--	constant pll_div : natural := 5;

	constant clk_freq : natural := 50000000;
	constant pll_mult : natural := 1;
	constant pll_div : natural := 1;

	constant irq_cnt : natural := 1;

end aua_config;

package body aua_config is

end aua_config;
