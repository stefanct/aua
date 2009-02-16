library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
-- used for address width calculation
use ieee.math_real.log2;
use ieee.math_real.ceil;

use work.aua_types.all;

--~ entity instr_cache is
	--~ port (
		--~ clk     : in std_logic;
		--~ reset	: in std_logic;
--~ 
		--~ -- cache/if
		--~ id_instr_addr	: in word_t;
		--~ id_instr_valid	: out std_logic;
		--~ id_instr		: out word_t;
		--~ -- cache/mmu
		--~ mmu_instr_addr	: out word_t;
		--~ mmu_enable		: out std_logic;
		--~ mmu_instr_valid	: in std_logic;
		--~ mmu_instr		: in word_t
	--~ );
--~ end instr_cache;

-- a direct mapped instruction cache for AUA
architecture cache_direct of instr_cache is
	constant WORDS_PER_LINE		: positive := 1;
	constant NUMBER_OF_LINES	: positive := 16;

	--~ constant LINE_SIZE	: positive := WORDS_PER_LINE * WORD_SIZE;
	constant WORD_BITS	: natural := reqbitsZ_for_choices(WORDS_PER_LINE); -- 0
	--~ subtype word_index_r is natural range WORD_BITS downto 1; -- 2 downto 1, word aligned addresses only
	constant LINE_BITS	: positive := reqbits_for_choices(NUMBER_OF_LINES); -- 5
	--~ subtype line_index_r is natural range LINE_BITS downto WORD_BITS+1; -- 7 downto 3
	constant TAG_BITS	: positive := WORD_SIZE-LINE_BITS-WORD_BITS-1; -- 16-5-2-1=8
	subtype tag_r is natural range WORD_SIZE-1 downto WORD_SIZE-TAG_BITS; -- 15 downto 8
	
	type line_t is array (natural range 0 to WORDS_PER_LINE-1) of word_t;
	subtype tag_t is std_logic_vector(tag_r);

	constant VEC_BITS : natural := TAG_BITS + 1 + WORDS_PER_LINE * WORD_SIZE;
	type entry_t is record
		tag		: tag_t;
		valid	: boolean;
		data	: line_t;
	  end record;

	type store_array_t is array(natural range 0 to NUMBER_OF_LINES-1) of entry_t;

 
function clear_entry return entry_t is
	variable ret_e : entry_t;
	begin
		ret_e.tag := (others => '0');
		ret_e.valid := false;
		for j in ret_e.data'range loop
			ret_e.data(j) := (others => '0');
		end loop;
		return ret_e;
end function;

function clear_array return store_array_t is
	variable return_array : store_array_t;
	begin
		for i in return_array'range loop
			return_array(i) := clear_entry;
		end loop;

		return return_array;
end function;

function get_word_idx (constant ADDR : word_t) return integer is
	begin
		if WORD_BITS = 0 then
			return 0;
		else
			return to_integer(unsigned(ADDR(WORD_BITS downto 1)));
		end if;
end function;

function get_line_idx (constant ADDR : word_t) return integer is
	variable ret : integer;
	begin
		--~ if WORD_BITS = 0 then
			--~ return to_integer(unsigned(ADDR(LINE_BITS downto WORD_BITS+1)));
		--~ else
			return to_integer(unsigned(ADDR(WORD_BITS+LINE_BITS downto WORD_BITS+1)));
end function;

-- encodes a cache entry (record) into a std_logic_vector
function entry2slv (constant E: in entry_t) return std_logic_vector is
	constant WORD_CNT : natural := E.data'length;
	constant TAG_SIZE : natural := E.tag'length;
	constant WORD_SIZE : natural := E.data(0)'length;
	constant VEC_BITS : natural := TAG_SIZE + 1 + WORD_CNT * WORD_SIZE;
	variable ret_vec : std_logic_vector(VEC_BITS-1 downto 0);
	variable vec_off : integer;
begin
		ret_vec(VEC_BITS-1 downto VEC_BITS-TAG_SIZE) := E.tag;
		ret_vec(VEC_BITS-TAG_SIZE-1) := bool2sl(E.valid);
		vec_off := VEC_BITS-TAG_SIZE-2;
		for i in E.data'range loop
			ret_vec(vec_off downto vec_off-WORD_SIZE+1) := E.data(i);
			vec_off := vec_off-WORD_SIZE;
		end loop;
	return ret_vec;
end function;

-- decodes the fields of a cache entry from a std_logic_vector
function slv2entry (constant V: in std_logic_vector) return entry_t is
	variable ret_e : entry_t;
	variable vec_off : integer;
begin
		ret_e.tag := V(VEC_BITS-1 downto VEC_BITS-TAG_BITS);
		ret_e.valid := sl2bool(V(VEC_BITS-TAG_BITS-1));
		vec_off := VEC_BITS-TAG_BITS-2;
		for i in 0 to WORDS_PER_LINE-1 loop
			ret_e.data(i) := V(vec_off downto vec_off-WORD_SIZE+1);
			vec_off := vec_off-WORD_SIZE;
		end loop;
	return ret_e;
end function;

	--~ constant init_store	: store_array_t := array_constructor;
	signal store		: store_array_t;
	signal store_nxt	: store_array_t;
	signal in_cache		: boolean;
	signal cur_line		: natural range 0 to NUMBER_OF_LINES-1;
	signal cur_word		: natural range 0 to WORDS_PER_LINE-1;
	--~ signal test	: std_logic_vector(VEC_BITS-1 downto 0);
	--~ signal testr	: entry_t;
begin
	mmu_enable <= not bool2sl(in_cache);
	mmu_instr_addr <= id_instr_addr;
	
	in_cache <= store(cur_line).valid and (store(cur_line).tag = id_instr_addr(tag_r));

	id_instr_valid <= '1' when in_cache else mmu_instr_valid;
	
	cur_line <= get_line_idx(id_instr_addr);
	cur_word <= get_word_idx(id_instr_addr);

	--~ test <= entry2slv(store(0));
	--~ testr <= slv2entry(test);

	--~ id_instr <= store(cur_line).data(0) when in_cache='1' else mmu_instr;
mux_res: process (reset, in_cache, store, cur_line, cur_word, id_instr_addr, mmu_instr)
	begin
		if reset = '1' then
			report "WORD_BITS="&integer'image(WORD_BITS)&", LINE_BITS="&integer'image(LINE_BITS)&", TAG_BITS="&integer'image(TAG_BITS);
			id_instr <= (others => '0');
		else
			if in_cache then
				id_instr <= store(cur_line).data(cur_word);
			else
				id_instr <= mmu_instr;
			end if;
		end if;
	end process;

	
cache_update: process (reset, store, cur_line, cur_word, in_cache, id_instr_addr, mmu_instr, mmu_instr_valid)
	begin
		if reset = '1' then
			--~ for i in store_nxt'range loop
				--~ store_nxt(i).tag <= (others => '0');
				--~ store_nxt(i).valid <= false;
				--~ for j in store_nxt(i).data'range loop
					--~ store_nxt(i).data(j) <= (others => '0');
				--~ end loop;
			--~ end loop;
			store_nxt <= clear_array;
		else
			store_nxt <= store;
			if mmu_instr_valid = '1' then
				store_nxt(cur_line).data(cur_word) <= mmu_instr;
				--~ store_nxt(cur_line).data(1) <= mmu_instr(7 downto 0)&mmu_instr(15 downto 8);
				--~ store_nxt(cur_line).data(3) <= x"0123";
				store_nxt(cur_line).valid <= true;
				store_nxt(cur_line).tag <= id_instr_addr(tag_r);
			end if;
		end if;
	end process;
	
sync: process (clk, reset)
	begin
		if reset = '1' then
			--~ for i in store'range loop
				--~ store(i).tag <= (others => '0');
				--~ store(i).valid <= false;
				--~ for j in store(i).data'range loop
					--~ store(i).data(j) <= (others => '0');
				--~ end loop;
			--~ end loop;
			store <= clear_array;
		elsif rising_edge(clk) then
			--~ for i in store'range loop
				--~ store(i).tag <= store_nxt(i).tag;
				--~ store(i).valid <= store_nxt(i).valid;
				--~ for j in store(i).data'range loop
					--~ store(i).data(j) <= store_nxt(i).data(j);
				--~ end loop;
			--~ end loop;
			store <= store_nxt;
		end if;
	end process;
	
end cache_direct;
