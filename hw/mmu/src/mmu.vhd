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
    begin
		instr_data <= (others => '0');

		io_address <= (others => '0');
		io_wr_data(31 downto 16) <= (others => '0');

		-- Speicher 16bit Adressen
		-- 0* --> SRAM
		process(instr_addr, ex_enable)
		begin
		    sram_addr <= (others => '0');
		    sram_dq <= (others => 'Z'); -- tri-state, 'Z' unless writing to SRAM
		    sram_we <= '1';
		    sram_oe <= '1'; -- why not...
		    sram_ub <= '0';
		    sram_lb <= '0';
		    sram_ce <= '0';
		    instr_valid <= '0';
		    
		    -- ueber die MMU laufen instruction fetch und EX - EX hat Vorrang, erst dann werden Instructions geholt
		    if(ex_enable = '1') then
		    	null;
		    else
		        if (instr_addr(15) = '0') then -- SRAM
   			         sram_addr(13 downto 0) <= instr_addr(14 downto 1); -- SRAM word, instr byte => shift
   			         instr_valid <= '1'; -- ACHTUNG!!! Stirbt wenn clk_freq > 50MHz
   			    else
   			        null;
	 		    end if; -- TODO: else fuer Simpcon Devices
	 		end if;
		end process;

		process(clk, reset)
		begin

			if (reset='1') then
				--ex_data(15 downto 0) <= (others => '0');
				ex_valid <= '0';

			elsif rising_edge(clk) then
				io_rd <= '0';
				io_wr <= '0';
				ex_valid <= '0';	-- no wait states
				if ex_opcode(1) = '1' then
						--ex_data(15 downto 0) <= io_rd_data(15 downto 0) ;
						io_rd <= '1';
				else
						--io_wr_data(15 downto 0) <= ex_data(15 downto 0);
						io_wr <= '1';
				end if;
			end if;

		end process;


    end sat1;
