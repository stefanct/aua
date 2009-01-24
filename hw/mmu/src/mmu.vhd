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
		ex_wr_data	: out word_t;
		ex_rd_data	: in word_t;
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
    
	ex_wr_data <= (others => '0');
	
	io_address <= (others => '0');
	io_wr_data(31 downto 16) <= (others => '0');

	-- Speicher 16bit Adressen
	-- 0* --> SRAM
	process(instr_addr, ex_enable, ex_opcode)
	begin
		sram_addr <= (others => '0');
		sram_dq <= (others => 'Z'); -- tri-state, 'Z' unless writing to SRAM
		sram_we <= '1';
		sram_oe <= '1'; -- why not...
		sram_ub <= '0';
		sram_lb <= '0';
		sram_ce <= '0';
		
		instr_data <= (others => '0');

		rom_addr <= (others => '0');
		
		instr_valid <= '0';
		ex_valid <= '0';
		
		-- ueber die MMU laufen instruction fetch und EX - EX hat Vorrang, erst dann werden Instructions geholt
		if(ex_enable = '1') then -- ex will was
			if(ex_opcode(1) = '1') then -- load
				if(instr_addr(15) = '0') then -- SRAM
					sram_addr(13 downto 0) <= instr_addr(14 downto 1);
				else
				    null; -- TODO: store
				end if;
			else -- store
			end if;
		else -- ex will nichts, instruction fetchen
			if (instr_addr(15) = '0') then -- SRAM
				 sram_addr(13 downto 0) <= instr_addr(14 downto 1); -- SRAM word, instr byte => shift
				 instr_valid <= '1'; -- ACHTUNG!!! Stirbt wenn clk_freq > 50MHz
			else -- nicht SRAM
				if(instr_addr(14 downto 12) = "000") then
				    instr_data <= rom_q;
				    instr_valid <= '1';
				end if;
			end if; -- TODO: else fuer Simpcon Devices
		end if;
	end process;


end sat1;
