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

			-- SimpCon slave interface to EX stage
			ex_address	: in word_t;
			ex_wr_data	: in word_t;
			ex_rd		: in std_logic;
			ex_wr		: in std_logic;
			ex_rd_data	: out word_t;
			ex_rdy_cnt	: out unsigned(1 downto 0);

			-- SimpCon interface to IO devices
			io_address	: out std_logic_vector(31 downto 0);
			io_wr_data	: out std_logic_vector(31 downto 0);
			io_rd		: out std_logic;
			io_wr		: out std_logic;
			io_rd_data	: in std_logic_vector(31 downto 0);
			io_rdy_cnt	: in unsigned(1 downto 0)
		);
    end mmu;

    architecture sat1 of mmu is
--	constant io_devs_name : io_devs := ("bla", "blu");
    begin
		instr_data <= (others => '0');

		io_address <= (others => '0');
		io_wr_data(31 downto 16) <= (others => '0');

		process(clk, reset)
		begin

			if (reset='1') then
				ex_rd_data(15 downto 0) <= (others => '0');
				ex_rdy_cnt <= (others => '0');

			elsif rising_edge(clk) then
				io_rd <= '0';
				io_wr <= '0';
				ex_rdy_cnt <= "00";	-- no wait states
				if ex_rd = '1' then
						ex_rd_data(15 downto 0) <= io_rd_data(15 downto 0) ;
						io_rd <= '1';
				end if;

				if ex_wr = '1' then
						io_wr_data(15 downto 0) <= ex_wr_data(15 downto 0);
						io_wr <= '1';
				end if;
			end if;

		end process;


    end sat1;