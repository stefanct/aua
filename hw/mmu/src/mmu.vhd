library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.aua_types.all;

entity mmu is
	generic (
		SLAVE_CNT	: natural := 0;
		SC_ADDR_BITS	: natural := 0;
		irq_cnt	: natural := 0
	);
	port (
		clk     : in std_logic;
		reset	: in std_logic;

		-- IF stage
		instr_addr	: in word_t;
		instr_data	: out word_t;
		instr_valid	: out std_logic;

		-- interface to EX stage
		ex_address	: in word_t;
		ex_rd_data	: out word_t;
		ex_wr_data	: in word_t;
		ex_enable	: in std_logic;
		ex_opcode	: in std_logic_vector(1 downto 0);
		ex_done		: out std_logic;
		
		-- SimpCon interfaces to IO devices
		sc_io_in		: in sc_in_t;
		sc_io_out		: out sc_out_t;
		
		-- interface to SRAM
		sram_addr	: out std_logic_vector(RAM_ADDR_SIZE-1  downto 0);
		sram_dq		: inout word_t;
		sram_we		: out std_logic -- write enable, low active, 0=enable, 1=disable
		--~ sram_oe		: out std_logic; -- output enable, low active
		--~ sram_ub		: out std_logic; -- upper byte, low active
		--~ sram_lb		: out std_logic; -- lower byte, low active
		--~ sram_ce		: out std_logic -- chip enable, low active
	);
end mmu;

architecture sat1 of mmu is
--	constant io_devs_name : io_devs := ("bla", "blu");

	signal sc_addr			: sc_addr_t;
	signal sc_wr_data		: sc_data_t;
	signal sc_rd, sc_wr		: std_logic;
	signal sc_rd_data		: sc_data_t;
	signal sc_rdy_cnt		: sc_rdy_cnt_t;

	signal sc_rd_state		: std_logic;
	signal sc_rd_state_nxt	: std_logic;

	signal address	: word_t; -- Addresse zu lesen (gemuxt Ex - Instr)
	signal write	: std_logic; -- schreiben=1, lesen=0 (gemuxt Ex - Instr)
	signal q		: word_t;
	signal done	: std_logic;

	component rom is
		port (
			clk     : in std_logic;
			address	: in word_t;
			q		: out word_t
		);
	end component;

	signal rom_addr	: word_t;
	signal rom_q	: word_t;

begin
    
    cmp_rom: rom
	port map(clk, rom_addr, rom_q);
    
	sc_io_out.address <= sc_addr;
	sc_io_out.wr_data <= sc_wr_data;
	sc_io_out.rd <= sc_rd;
	sc_io_out.wr <= sc_wr;
	sc_rd_data <= sc_io_in.rd_data;
	sc_rdy_cnt <= sc_io_in.rdy_cnt;

	-- Speicher 16bit Adressen
	-- 0* --> SRAM
	-- 10* --> non-Simpcon
	-- 1000* --> ROM
	-- 11* --> Simpcon 0xC000/2

mmu_get_addr: process(instr_addr, ex_address, ex_enable, ex_opcode)
	begin
	    if(ex_enable = '1') then
	        address <= ex_address;
	        write <= ex_opcode(1);
		else
		    address <= instr_addr;
		    write <= '0';
	    end if;
	end process;

mmu_load_store: process(address, write, ex_enable, ex_wr_data, sram_dq, rom_q, sc_rd, sc_rdy_cnt, sc_rd_data, sc_rd_state)
	begin
		sram_addr <= (others => '0');
		sram_dq <= (others => 'Z'); -- tri-state, 'Z' unless writing to SRAM
		sram_we <= '1';
		--~ sram_oe <= '1'; -- why not...
		--~ sram_ub <= '0';
		--~ sram_lb <= '0';
		--~ sram_ce <= '0';
		
		sc_addr <= (others => '0');
		sc_wr_data <= (others => '0');
		sc_rd <= '0';
		sc_wr <= '0';
		
		rom_addr <= (others => '0');
		
		q <= (others => '0');
		
		done <= '0';
		sc_rd_state_nxt <= '0';
		
		if(address(15) = '0') then -- SRAM
			sram_addr(13 downto 0) <= address(14 downto 1); -- SRAM adressiert word, instr byte => shift
			if(write = '1') then
			    sram_we <= '0';
			    sram_dq <= ex_wr_data;
			    done <= '1';
			else
				q <= sram_dq;
				done <= '1';
			end if;
		else
		    if(address(14) = '0') then -- non-Simpcon
		    	if(address(13) = '0') then -- ROM (write wird ignoriert)
		    		rom_addr <= address;
		    		q <= rom_q;
		    		done <= '1';
		    	end if;
			else -- Simpcon
		    	sc_addr <= address;
		    	if(write = '1') then
		    	    sc_wr <= '1';
		    	    sc_wr_data(15 downto 0) <= ex_wr_data;
					done <= '1'; -- assumes that writes complete instantly
				else
					if sc_rdy_cnt > 0 or sc_rd_state = '0' then
						sc_rd <= '1';
						sc_rd_state_nxt <= '1';
					else
						q <= sc_rd_data(15 downto 0);
						done <= '1';
					end if;
				end if;
		    end if;
	    end if;
	end process;
	
mmu_return_result: process(ex_enable, q, done)
	begin
	    instr_data <= (others => '0');
	    ex_rd_data <= (others => '0');

		instr_valid <= '0';
		ex_done <= '0';
		
		if(ex_enable = '1') then
	        ex_rd_data <= q;
	        ex_done <= done;
	    else
	        instr_data <= q;
	        instr_valid <= done;
	    end if;
	end process;

sync: process (clk, reset)
	begin
		if reset = '1' then
			sc_rd_state <= '0';
		elsif rising_edge(clk) then
			sc_rd_state <= sc_rd_state_nxt;
		end if;
	end process;
	
end sat1;
