    library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

    entity id is
		port (
			clk     : in std_logic;
			reset	: in std_logic;

			-- pipeline register inputs
			opcode	: in std_logic_vector(5 downto 0);
			dest	: in std_logic_vector(4 downto 0);
			pc		: in std_logic_vector(15 downto 0);
			rega	: in std_logic_vector(4 downto 0);
			regb	: in std_logic_vector(4 downto 0);
			imm		: in std_logic_vector(7 downto 0);

			-- results from wb to reg file
			regr	: in std_logic_vector(4 downto 0);
			valr	: in std_logic_vector(15 downto 0);

			-- pipeline register outputs
			opcode_out	: out std_logic_vector(5 downto 0);
			dest_out	: out std_logic_vector(4 downto 0);
			opa			: out std_logic_vector(15 downto 0);
			opb			: out std_logic_vector(15 downto 0);

			-- branch decision
			pc_out		: out std_logic_vector(15 downto 0);
			branch_out	: out std_logic
		);
    end id;

    architecture sat1 of id is
		component reg is
			port (
				reset	: in std_logic;
				rega	: in std_logic_vector(4 downto 0);
				regb	: in std_logic_vector(4 downto 0);

				regr	: in std_logic_vector(4 downto 0);
				valr	: in std_logic_vector(15 downto 0);

				vala	: out std_logic_vector(15 downto 0);
				valb	: out std_logic_vector(15 downto 0)
			);
		end component;


--        constant CLK_FREQ : integer := 50000000; -- 20M for cycore; 50M for de2
--		type state_type		is (st_init, st_wait, st_rdst, st_rdcmd, st_flood_adr, st_flood);
--		signal state 		: state_type;
--		signal sc_adr	: std_logic_vector(0 downto 0);
		signal opcode_nxt	: std_logic_vector(5 downto 0);
		signal dest_nxt		: std_logic_vector(4 downto 0);
		signal opa_nxt		: std_logic_vector(15 downto 0);
		signal opb_nxt		: std_logic_vector(15 downto 0);
		signal pc_nxt		: std_logic_vector(15 downto 0);
		signal branch_nxt	: std_logic;
	
	begin

		opcode_nxt <= (others => '0');
		dest_nxt <= (others => '0');
		opa_nxt <= (others => '0');
		opb_nxt <= (others => '0');
		pc_nxt <= (others => '0');
		branch_nxt <= '0';

		process(clk, reset)
		begin
			if reset = '1' then
			elsif rising_edge(clk) then
				opcode_out <= opcode_nxt;
				dest_out <= dest_nxt;
				opa <= opa_nxt;
				opb <= opb_nxt;
				pc_out <= pc_nxt;
				branch_out <= branch_nxt;
			end if;
		end process;
    end sat1;