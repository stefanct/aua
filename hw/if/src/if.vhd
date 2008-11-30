    library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

    entity ent_if is
		port (
			clk     : in std_logic;
			reset	: in std_logic;

			-- pipeline register outputs
			opcode	: out std_logic_vector(5 downto 0);
			dest	: out std_logic_vector(4 downto 0);
			pc_out	: out std_logic_vector(15 downto 0);
			rega	: out std_logic_vector(4 downto 0);
			regb	: out std_logic_vector(4 downto 0);
			imm		: out std_logic_vector(7 downto 0);

			-- branches (from ID)
			pc_in		: in std_logic_vector(15 downto 0);
			branch		: in std_logic;

			-- mmu
			instr_addr	: out std_logic_vector(15 downto 0);
			instr_data	: in std_logic_vector(15 downto 0)

		);
    end ent_if;

    architecture sat1 of ent_if is
--		component alu is
--			port (
--				clk     : in std_logic;
--				reset	: in std_logic;
--				opcode	: in std_logic_vector(5 downto 0);
--				opa		: in std_logic_vector(15 downto 0);
--				opb		: in std_logic_vector(15 downto 0);
--				result	: out std_logic_vector(15 downto 0)
--			);
--		end component;


--        constant CLK_FREQ : integer := 50000000; -- 20M for cycore; 50M for de2
--		type state_type		is (st_init, st_wait, st_rdst, st_rdcmd, st_flood_adr, st_flood);
--		signal state 		: state_type;
--		signal sc_adr	: std_logic_vector(0 downto 0);
		signal opcode_nxt	: std_logic_vector(5 downto 0);
		signal dest_nxt		: std_logic_vector(4 downto 0);
		signal rega_nxt		: std_logic_vector(4 downto 0);
		signal regb_nxt		: std_logic_vector(4 downto 0);
		signal imm_nxt		: std_logic_vector(7 downto 0);
    begin

		opcode_nxt <= (others => '0');
		dest_nxt <= (others => '0');
		rega_nxt <= (others => '0');
		regb_nxt <= (others => '0');
		imm_nxt <= (others => '0');
		
		pc_out <= (others => '0');
		instr_addr <= (others => '0');
		
		process(clk, reset)
		begin
			if reset = '1' then
			elsif rising_edge(clk) then
				opcode <= opcode_nxt;
				dest <= dest_nxt;
				rega <= rega_nxt;
				regb <= regb_nxt;
				imm <= imm_nxt;
			end if;
		end process;
    end sat1;