library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use ieee.math_real.log2;
use ieee.math_real.ceil;
use ieee.math_real.floor;

use work.aua_types.all;

entity mmu is
	generic (
		CLK_FREQ		: natural;
		SRAM_RD_FREQ	: natural;
		SRAM_WR_FREQ	: natural
	);
	port (
		clk     : in std_logic;
		reset	: in std_logic;

		-- IF stage/cache
		instr_addr	: in word_t;
		instr_enable: in std_logic;
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
		sram_we		: out std_logic; -- write enable, low active, 0=enable, 1=disable
		
		--~ sram_oe		: out std_logic; -- output enable, low active
		sram_ub		: out std_logic; -- upper byte, low active
		sram_lb		: out std_logic -- lower byte, low active
		--~ sram_ce		: out std_logic -- chip enable, low active
	);
end mmu;

architecture sat1 of mmu is
--	constant io_devs_name : io_devs := ("bla", "blu");

	constant SRAM_RD_RATIO : real := real(CLK_FREQ)/real(SRAM_RD_FREQ);
	constant SRAM_WR_RATIO : real := real(CLK_FREQ)/real(SRAM_WR_FREQ);
--	constant SRAM_WAIT_WIDTH	: integer := integer(ceil(log2(max(real(5), real(7))))); 
	constant SRAM_WAIT_WIDTH	: integer := integer(ceil(log2(max(SRAM_RD_RATIO, SRAM_WR_RATIO)))) + 1; 

	signal sc_addr			: sc_addr_t;
	signal sc_addr_nxt		: sc_addr_t;
	signal sc_addr_out 		: sc_addr_t;
	signal sc_wr_data		: sc_data_t;
	signal sc_rd, sc_wr		: std_logic;
	signal sc_rd_data		: sc_data_t;
	signal sc_rdy_cnt		: sc_rdy_cnt_t;

	type mmu_state_t is (mmu_idle, scst_init_rd, scst_rd, scst_init_wr, scst_wr, st_sram); -- Request selbst, Simpcon, kein Simpcon
	signal mmu_state		: mmu_state_t;
	signal mmu_state_nxt	: mmu_state_t;
	--signal sc_rd_state		: std_logic;
	--signal sc_rd_state_nxt	: std_logic;

	signal address	: word_t; -- Addresse zu lesen (gemuxt Ex - Instr)
	signal write	: std_logic; -- schreiben=1, lesen=0 (gemuxt Ex - Instr)
	signal q		: word_t;
	signal done	: std_logic; 
	
	signal sram_a	: std_logic_vector(RAM_ADDR_SIZE-1 downto 0);
	signal sram_d	: word_t;
	signal sram_w	: std_logic;
	
	signal sram_a_nxt	: std_logic_vector(RAM_ADDR_SIZE-1 downto 0);
	signal sram_d_nxt	: word_t;
	signal sram_w_nxt	: std_logic;
	
	signal sram_wait	: unsigned(SRAM_WAIT_WIDTH-1 downto 0);
	signal sram_wait_nxt	: unsigned(SRAM_WAIT_WIDTH-1 downto 0);
	
	signal sram_writing	: std_logic;
	signal sram_writing_nxt	: std_logic;
	
	signal sram_b_en	: std_logic_vector(1 downto 0);
	signal sram_b_en_nxt	: std_logic_vector(1 downto 0);

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
    
    sc_io_out.address <= sc_addr_out;
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

sc_addr_write: process(sc_addr, sc_addr_nxt)
	begin
	    if sc_addr = x"0000" then
	    	sc_addr_out <= sc_addr_nxt;
	   	else
	   	    sc_addr_out <= sc_addr;
		end if;
	end process;

sram: process(sram_a_nxt, sram_w_nxt, sram_b_en_nxt)
	begin
	    sram_addr <= sram_a_nxt;
	    sram_we <= sram_w_nxt;
	    sram_ub <= sram_b_en_nxt(0);
	    sram_lb <= sram_b_en_nxt(1);
	end process;

mmu_load_store: process(address, write, ex_enable, ex_wr_data, sram_dq, sram_b_en, rom_q, sc_rd, sc_rdy_cnt, sc_rd_data, mmu_state, sc_addr, sram_wait, sram_a, sram_d, sram_w, sram_writing, ex_opcode)
	begin
		sram_a_nxt <= (others => '0');
		sram_d_nxt <= (others => '0'); -- tri-state, 'Z' unless writing to SRAM
		sram_w_nxt <= '1';
		sram_wait_nxt <= TO_UNSIGNED(10, SRAM_WAIT_WIDTH);
		sram_writing_nxt <= sram_writing;
		sram_b_en_nxt <= "00";
		
		sram_dq <= (others => 'Z');
		
		sc_wr_data <= (others => '0');
		sc_rd <= '0';
		sc_wr <= '0';
		
		rom_addr <= (others => '0');
		
		q <= (others => '0');
		
		done <= '0';
		mmu_state_nxt <= mmu_state;
		sc_addr_nxt <= x"0000";
		
		case mmu_state is
		    
			when mmu_idle =>
     		if(address(15) = '0') then -- SRAM
     			sram_a_nxt(13 downto 0) <= address(14 downto 1); -- SRAM adressiert word, instr byte => shift
     			if(ex_opcode(1) = '1') and (ex_enable = '1') then
     			    sram_b_en_nxt <= address(0) & not address(0);
     			    --if(address(0) = '0') then
     			    --    sram_b_en_nxt <= "01";
     			    --else
     			    --    sram_b_en_nxt <= "10";
     			    --end if;
     			end if;
     			if(write = '1') then
     			    sram_w_nxt <= '0';
     			    sram_d_nxt <= ex_wr_data;
     			    sram_dq <= ex_wr_data;
     			    if(CLK_FREQ > SRAM_WR_FREQ) then
     			        sram_wait_nxt <= TO_UNSIGNED(0, 2);--TO_UNSIGNED(natural(floor(SRAM_WR_RATIO)), SRAM_WAIT_WIDTH) - 1;
     			        mmu_state_nxt <= st_sram;
     			        sram_writing_nxt <= '1';
     				else
	     			    done <= '1';
     			    end if;
     			else
     			    if(CLK_FREQ > SRAM_RD_FREQ) then
     			        sram_wait_nxt <= TO_UNSIGNED(0, 2);--TO_UNSIGNED(natural(floor(SRAM_RD_RATIO)), SRAM_WAIT_WIDTH) - 1;
     			        mmu_state_nxt <= st_sram;
     			    else
     					q <= sram_dq;
     					done <= '1';
     				end if;
     			end if;
     		else
     		    if(address(14) = '0') then -- non-Simpcon
     		    	if(address(13) = '0') then -- ROM (write wird ignoriert)
     		    		rom_addr <= address;
     		    		q <= rom_q;
     		    		done <= '1';
     		    	end if;
     			else -- Simpcon
     		    	sc_addr_nxt <= address;
     		    	if(write = '1') then
     		    	    sc_wr <= '1';
     		    	    sc_wr_data(15 downto 0) <= ex_wr_data;
     		    	    mmu_state_nxt <= scst_init_rd;
     				else
     					sc_rd <= '1';
     					mmu_state_nxt <= scst_init_rd;
     				end if;
     		    end if;
     	    end if;

			when st_sram =>
				sram_a_nxt <= sram_a;
				sram_d_nxt <= sram_d;
				sram_w_nxt <= sram_w;
				if sram_wait = 0 then
				    done <= '1';
				    mmu_state_nxt <= mmu_idle;
				    sram_writing_nxt <= '0';
				    if sram_writing = '0' then
				        q <= sram_dq;
				    end if;
				else
				    sram_wait_nxt <= sram_wait - 1;
				    mmu_state_nxt <= st_sram;
				    sram_writing_nxt <= sram_writing;
				end if;
				sram_b_en_nxt <= sram_b_en;

		    when scst_init_rd =>
		    	mmu_state_nxt <= scst_rd;
		    	sc_addr_nxt <= sc_addr;
		    
		    when scst_rd =>
			if sc_rdy_cnt > 0 then
			    sc_addr_nxt <= sc_addr;
			else
			    mmu_state_nxt <= mmu_idle;
			    done <= '1';
			    q <= sc_rd_data(15 downto 0);
			 end if;

			when scst_init_wr =>
				mmu_state_nxt <= scst_wr;
				sc_addr_nxt <= sc_addr;
			
			when scst_wr =>
				if sc_rdy_cnt > 0 then
				    sc_addr_nxt <= sc_addr;
				else
				    mmu_state_nxt <= mmu_idle;
				    done <= '1';
				end if;
				
			when others =>
				mmu_state_nxt <= mmu_idle;
    	end case;
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
			mmu_state <= mmu_idle;
		    sc_addr <= (others => '0');
		    sram_wait <= TO_UNSIGNED(0, SRAM_WAIT_WIDTH);
		elsif rising_edge(clk) then
			mmu_state <= mmu_state_nxt;
		    sc_addr <= sc_addr_nxt;
		    
		    sram_a <= sram_a_nxt;
		    sram_d <= sram_d_nxt;
		    sram_w <= sram_w_nxt;
		    sram_writing <= sram_writing_nxt;
		    sram_wait <= sram_wait_nxt;
		    sram_b_en <= sram_b_en_nxt;
		end if;
	end process;
	
end sat1;
