    library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

	use work.aua_types.all;

	entity id is
		port (
			clk     : in std_logic;
			reset	: in std_logic;

			-- pipeline register inputs
			opcode	: in opcode_t;
			dest	: in reg_t;
			pc		: in word_t;
			rega	: in reg_t;
			regb	: in reg_t;
			imm		: in std_logic_vector(7 downto 0);

			-- asynchron register inputs
			async_rega	: in reg_t;
			async_regb	: in reg_t;

			-- results from wb to reg file
			regr	: in reg_t;
			valr	: in word_t;

			-- pipeline register outputs
			opcode_out	: out opcode_t;
			dest_out	: out reg_t;
			opa			: out word_t;
			opb			: out word_t;

			-- branch decision
			pc_out		: out word_t;
			branch_out	: out std_logic
		);
    end id;

    architecture sat1 of id is
		component reg is
			port (
				clock	: in std_logic;
				reset	: in std_logic;
				rega	: in reg_t;
				regb	: in reg_t;

				regr	: in reg_t;
				valr	: in word_t;

				vala	: out word_t;
				valb	: out word_t
			);
		end component;


--        constant CLK_FREQ : integer := 50000000; -- 20M for cycore; 50M for de2
--		type state_type		is (st_init, st_wait, st_rdst, st_rdcmd, st_flood_adr, st_flood);
--		signal state 		: state_type;
--		signal sc_adr	: std_logic_vector(0 downto 0);
		signal opcode_nxt	: opcode_t;
		signal dest_nxt		: reg_t;
		signal opa_nxt		: word_t;
		signal opb_nxt		: word_t;
		signal pc_nxt		: word_t;
		signal branch_nxt	: std_logic;
		signal vala			: word_t;
		signal valb			: word_t;
		
		signal regb_done	: word_t;
		signal opb_override	: std_logic;
		signal opb_branch	: word_t;
	
	begin
		cmp_reg : reg
			port map(clk, reset, async_rega, async_regb, regr, valr, vala, valb);

		pc_nxt <= std_logic_vector(unsigned(pc) + unsigned(opb_nxt));


		-- branch?
		branch: process (opcode,opa_nxt,pc,dest)
			variable inv : std_ulogic;
			variable brinstr : std_ulogic;
		begin
			inv := '0';
			brinstr := '0';

			opcode_nxt <= opcode;
			dest_nxt <= dest;
			opb_branch <= pc;
			opb_override <= '0';
			
			if opcode(5 downto 3)="010" then
				inv := opcode(2);
				brinstr := '1';
			elsif opcode(5 downto 1) ="00111" then
				inv := opcode(0);
				brinstr := '1';
			elsif opcode = "001101" then
				inv := '0'; -- jmpl, schedule mov r31, pc!
					opcode_nxt <= "111011";
					opb_override <= '1';
					dest_nxt <= "11111";
				brinstr := '1';
			end if;
			
			if ((std_logic_vector(to_unsigned(0, 16)))=opa_nxt xor inv='1') and brinstr='1' then
				branch_nxt <= '1';
			else
				branch_nxt <= '0';
			end if;
		end process;

		-- sign extend, expand and mux with regb
		extend: process (opcode,imm,regb_done,opb_branch,opb_override)
		begin
		   if opcode(5 downto 3)="000" then
		      opb_nxt <= (15 downto 8 => '0') & imm(7 downto 0);
			elsif opcode(5 downto 2) ="1100" or opcode(5 downto 0) ="111010" then
				--expand whole imm (alu has to take care if thats "too much")
				opb_nxt <= (15 downto 7 => '0') & imm(6 downto 0);
			elsif opcode(5 downto 4)="01" then
				--sign extend imm(6 downto 0)
				opb_nxt <= (15 downto 7 => imm(6)) & imm(6 downto 0);
			elsif opb_override='1' then
				opb_nxt <= opb_branch;
			else
				opb_nxt <= regb_done;
			end if;
		end process;
		
		-- hide r0 changes
		r0readonly: process (rega, regb, vala, valb)
		begin
			if rega=(4 downto 0=>'0') then
				opa_nxt <= (others => '0');
			else
				opa_nxt <= vala;
			end if;

			if regb=(4 downto 0=>'0') then
				regb_done <= (others => '0');
			else
				regb_done <= valb;
			end if;
		end process;
		
		
		sync: process (clk, reset)
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