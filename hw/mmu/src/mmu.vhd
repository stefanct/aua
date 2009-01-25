library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.aua_types.all;

entity mmu is
	generic (
		irq_cnt	: natural
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
		ex_wr_data	: in word_t;
		ex_rd_data	: out word_t;
		ex_enable	: in std_logic;
		ex_opcode	: in std_logic_vector(1 downto 0);
		ex_valid	: out std_logic;
		
		-- SimpCon interface to IO devices
		io_address	: out std_logic_vector(31 downto 0);
		io_wr_data	: out std_logic_vector(31 downto 0);
		io_rd		: out std_logic;
		io_wr		: out std_logic;
		io_rd_data	: in std_logic_vector(31 downto 0);
		io_rdy_cnt	: in unsigned(1 downto 0);
		
		-- interface to SRAM
		sram_addr	: out std_logic_vector(17 downto 0);
		sram_dq		: inout word_t;
		sram_we		: out std_logic; -- write enable, low active, 0=enable, 1=disable
		sram_oe		: out std_logic; -- output enable, low active
		sram_ub		: out std_logic; -- upper byte, low active
		sram_lb		: out std_logic; -- lower byte, low active
		sram_ce		: out std_logic -- chip enable, low active
	);
end mmu;

architecture sat1 of mmu is
--	constant io_devs_name : io_devs := ("bla", "blu");

	signal address	: std_logic_vector(15 downto 0); -- Addresse zu lesen (gemuxt Ex - Instr)
	signal write	: std_logic; -- schreiben=1, lesen=0 (gemuxt Ex - Instr)
	signal q_out	: std_logic_vector(15 downto 0);
	signal valid	: std_logic;

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
	port map(clk, instr_addr, rom_q);
    
	-- Speicher 16bit Adressen
	-- 0*		--> SRAM
	-- 1*		--> Blöcke /4
		-- 10*	--> non-Simpcon
			-- 1000*	--> ROM
		-- 11*	--> Simpcon
  			-- 1111*	--> Blöcke /8
  				-- 11111111*	--> Blöcke /12 (I/O Devices)
  					-- 111111110000*	--> Switches
  					-- 111111110001*	--> Digits

	mmu_get_addr: process(instr_addr, ex_address, ex_enable)
	begin
	    if(ex_enable = '1') then
	        address <= ex_address;
	        write <= ex_opcode(1);
		else
		    address <= instr_addr;
		    write <= '0';
	    end if;
	end process;

	mmu_load_store: process(address, write, ex_enable, ex_wr_data, sram_dq, rom_q)
	begin
		sram_addr <= (others => '0');
		sram_dq <= (others => 'Z'); -- tri-state, 'Z' unless writing to SRAM
		sram_we <= '1';
		sram_oe <= '1'; -- why not...
		sram_ub <= '0';
		sram_lb <= '0';
		sram_ce <= '0';
		
		io_address <= (others => '0');
		io_wr_data <= (others => '0');
		io_rd <= '0';
		io_wr <= '0';
		
		rom_addr <= (others => '0');
		
		q_out <= (others => '0');
		
		valid <= '0';
		
		if(address(15) = '0') then -- SRAM
			sram_addr(13 downto 0) <= address(14 downto 1); -- SRAM adressiert word, instr byte => shift
			if(write = '1') then
			    null; -- TODO
			else
				q_out <= sram_dq;
				valid <= '1';
			end if;
		else
		    if(address(14) = '0') then -- non-Simpcon
		    	if(address(13) = '0') then -- ROM
		    		rom_addr <= address;
		    		q_out <= rom_q;
		    		valid <= '1';
		    	end if;
			else -- Simpcon
		    	io_address(15 downto 0) <= address;
		    	if(write = '1') then
		    	    io_wr <= '1';
		    	    io_wr_data(15 downto 0) <= ex_wr_data;
		    	end if;
		    end if;
	    end if;
	end process;
	
	mmu_return_result: process(ex_enable, q_out, valid)
	begin
	    instr_data <= (others => '0');
	    ex_rd_data <= (others => '0');

		instr_valid <= '0';
		ex_valid <= '0';
		
		if(ex_enable = '1') then
	        ex_rd_data <= q_out;
	        ex_valid <= valid;
	    else
	        instr_data <= q_out;
	        instr_valid <= valid;
	    end if;
	end process;
	
end sat1;
