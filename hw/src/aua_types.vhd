library ieee;
use ieee.std_logic_1164.all;

package aua_types is

--	type io_devs is array(natural range <>) of component;
	subtype word_t is std_logic_vector(15 downto 0);
	subtype opcode_t is std_logic_vector(5 downto 0);
	subtype reg_t is std_logic_vector(4 downto 0);


end aua_types;

package body aua_types is

end aua_types;
