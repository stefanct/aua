    library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

    entity mmu is
		port (
			clk     : in std_logic;
			reset	: in std_logic;

			-- IF stage
			instr_addr	: in std_logic_vector(15 downto 0);
			instr_data	: out std_logic_vector(15 downto 0);

			-- SimpCon slave interface to EX stage
			ex_address	: in std_logic_vector(15 downto 0);
			ex_wr_data	: in std_logic_vector(31 downto 0);
			ex_rd		: in std_logic;
			ex_wr		: in std_logic;
			ex_rd_data	: out std_logic_vector(31 downto 0);
			ex_rdy_cnt	: out unsigned(1 downto 0);

			-- SimpCon interface to IO devices
			io_address	: out std_logic_vector(15 downto 0);
			io_wr_data	: out std_logic_vector(31 downto 0);
			io_rd		: out std_logic;
			io_wr		: out std_logic;
			io_rd_data	: in std_logic_vector(31 downto 0);
			io_rdy_cnt	: in unsigned(1 downto 0)
		);
    end mmu;

    architecture sat1 of mmu is
    begin
		instr_data <= (others => '0');

		ex_rd_data <= (others => '0');
		ex_rdy_cnt <= (others => '0');

		io_address <= (others => '0');
		io_wr_data <= (others => '0');
		io_rd <= '0';
		io_wr <= '0';

    end sat1;