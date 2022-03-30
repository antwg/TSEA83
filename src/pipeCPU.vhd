library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity pipeCPU is
	port (
		clk : in std_logic;
		rst : in std_logic
	);
end pipeCPU;

architecture func of pipeCPU is

----------------------------- Internal signals --------------------------------
signal IR1 : unsigned(25 downto 0); -- Fetch stage
alias IR1_op : unsigned(5 downto 0) is IR1(25 downto 20);
alias IR1_rd : unsigned(3 downto 0) is IR1(19 downto 16);
alias IR1_ra : unsigned(3 downto 0) is IR1(15 downto 12);
alias IR1_const : unsigned(15 downto 0) is IR1(15 downto 0);

signal IR2 : unsigned(25 downto 0); -- Decode stage
alias IR2_op : unsigned(5 downto 0) is IR2(25 downto 20);
alias IR2_rd : unsigned(3 downto 0) is IR2(19 downto 16);
alias IR2_ra : unsigned(3 downto 0) is IR2(15 downto 12);
alias IR2_const : unsigned(15 downto 0) is IR2(15 downto 0);

-- Stack pointer
signal SP : unsigned(15 downto 0);

-- Status register
signal status_reg : unsigned(4 downto 0);
alias ZF : std_logic is status_reg(0);
alias NF : std_logic is status_reg(1);
alias CF : std_logic is status_reg(2);
alias VF : std_logic is status_reg(3);
--alias F : std_logic is status_reg(4);

signal PC, PC1, PC2 : unsigned(15 downto 0);

signal PMdata_out : unsigned(25 downto 0);
signal pm_addr : unsigned(15 downto 0);

-- Data memory
signal dm_addr, dm_data_out, dm_data_in : unsigned(15 downto 0);
signal dm_we : std_logic;

-- Sprite memory
signal sm_addr : unsigned(15 downto 0);
signal sm_we : std_logic;

-- ALU
signal alu_out, alu_mux1, alu_mux2 : unsigned(15 downto 0);

-- Data bus
signal data_bus : unsigned(15 downto 0);

-- Register file
signal rf_we : std_logic;
signal rf_out1, rf_out2 : unsigned(15 downto 0);

-- Instructions
constant NOP 		: unsigned(5 downto 0) := "000000";
constant RJMP		: unsigned(5 downto 0) := "000001";
constant BEQ		: unsigned(5 downto 0) := "000010";
constant BNE 		: unsigned(5 downto 0) := "000011";
constant BPL 		: unsigned(5 downto 0) := "000100";
constant BMI 		: unsigned(5 downto 0) := "000101";
constant BGE 		: unsigned(5 downto 0) := "000111";
constant BLT 		: unsigned(5 downto 0) := "001000";
constant LDI 		: unsigned(5 downto 0) := "001001";
constant LD 		: unsigned(5 downto 0) := "001010";
constant STI 		: unsigned(5 downto 0) := "001011";
constant ST  		: unsigned(5 downto 0) := "001100";
constant COPY		: unsigned(5 downto 0) := "001101";
constant ADD		: unsigned(5 downto 0) := "001111";
constant ADDI		: unsigned(5 downto 0) := "010000";
constant SUB		: unsigned(5 downto 0) := "010001";
constant SUBI		: unsigned(5 downto 0) := "010010";
constant CMP		: unsigned(5 downto 0) := "010011";
constant CMPI		: unsigned(5 downto 0) := "100100";
constant I_AND	: unsigned(5 downto 0) := "010100";
constant ANDI		: unsigned(5 downto 0) := "010101";
constant I_OR		: unsigned(5 downto 0) := "010111";
constant ORI		: unsigned(5 downto 0) := "011000";
constant PUSH		: unsigned(5 downto 0) := "011001";
constant POP		: unsigned(5 downto 0) := "011010";
constant ADC		: unsigned(5 downto 0) := "011011";
constant SBC 		: unsigned(5 downto 0) := "011100";
constant MUL 		: unsigned(5 downto 0) := "011101";
constant MULI 	: unsigned(5 downto 0) := "011111";
constant MULS		: unsigned(5 downto 0) := "100000";
constant MULSI	: unsigned(5 downto 0) := "100001";
constant LSLS		: unsigned(5 downto 0) := "100010";
constant LSLR		: unsigned(5 downto 0) := "100011";


------------------------------------ Def components ---------------------------

component PROG_MEM is
	port(
		addr : in unsigned(15 downto 0);
		data_out : out unsigned(25 downto 0)
		);
end component;

component DATA_MEM is
	port(
		addr : in unsigned(15 downto 0);
		data_in : in unsigned(15 downto 0);
		we : in std_logic; -- write enable
		clk : in std_logic;
		data_out : out unsigned(15 downto 0)
		);
end component;

-- Sprite minne
-- address
-- we

component REG_FILE is
	port(
    rd : in unsigned(3 downto 0);
    ra : in unsigned(3 downto 0);
		we : in std_logic; -- write enable
		clk : in std_logic;
		data_in : in unsigned(15 downto 0);
		rd_out : out unsigned(15 downto 0);
		ra_out : out unsigned(15 downto 0)
		);
end component;

component ALU is
	port (
	MUX1: in unsigned(15 downto 0);
	MUX2 : in unsigned(15 downto 0);
	op_code : in unsigned(5 downto 0);
	result : out unsigned(15 downto 0)
	);
end component;

begin

------------------------------------ Components -------------------------------

	prog_mem_comp : PROG_MEM port map(
		addr => pm_addr,
		data_out => PMdata_out
	);

	reg_file_comp : REG_FILE port map(
		rd => IR2_rd,
		ra => IR2_ra,
		rd_out => rf_out1,
		ra_out => rf_out2,
		we => rf_we,
		data_in => data_bus,
		clk => clk
	);

	data_mem_comp : DATA_MEM port map(
			addr => alu_out,
			we => dm_we,
			data_out => dm_data_out,
			data_in => dm_data_in,
			clk => clk
	);

	alu_comp : ALU port map(
			op_code => IR2_op,
			result => alu_out,
			MUX1 => alu_mux1,
			MUX2 => alu_mux2
	);

-------------------------------------------------------------------------------

	-- ALU multiplexers

	-- TODO Add i++ for stack pointer
	alu_mux1 <= rf_out1;

	alu_mux2 <= IR2_const when ((IR2_op = LDI) or (IR2_op = STI) or
															(IR2_op = ADDI) or (IR2_op = SUBI) or
															(IR2_op = CMPI) or (IR2_op = ANDI) or
															(IR2_op = ORI) or (IR2_op = MULI) or
															(IR2_op = MULSI))
												else rf_out2;


	-- Data bus multiplexer
	data_bus <= IR2_const when (IR2_op = LDI) else
							rf_out1 when (IR2_op = COPY) else
							dm_data_out when (IR2_op = LD) else
							alu_out;

	-- Address controller
	dm_addr <= alu_out;
	dm_we <= '1' when (alu_out <= x"FC00") else '0';

	sm_addr <= (alu_out and "0000001111111111");
	sm_we <= '0' when (alu_out <= x"FC00") else '1';

	-- If jmp instruction, take value from IR2, else increment
	process(clk)
	begin
		if rising_edge(clk) then
			if (rst='1') then
				PC <= (others => '0');
			elsif (IR2_op = RJMP) then
				PC <= PC2;
			else
				PC <= PC + 1;
			end if;
		end if;
	end process;

	pm_addr <= PC(15 downto 0);

	-- Update PC1 by copying PC
	process(clk)
	begin
		if rising_edge(clk) then
			if (rst='1') then
				PC1 <= (others => '0');
			else
				PC1 <= PC;
			end if;
		end if;
	end process;

	-- Update PC2, jump if needed
	process(clk)
	begin
		if rising_edge(clk) then
			if (rst='1') then
				PC2 <= (others => '0');
			else
				PC2 <= PC1 + IR1_const;
			end if;
		end if;
	end process;

	-- Load IR1 NOP if jmp instruction, else read from PM
	process(clk)
	begin
		if rising_edge(clk) then
			if (rst='1') then
				IR1 <= (others => '0');
			elsif (IR2_op = RJMP) then
				IR1_op <= NOP;
			else
				IR1 <= PMdata_out(25 downto 0);
			end if;
		end if;
	end process;

	-- Update IR2, copies IR1
	process(clk)
	begin
		if rising_edge(clk) then
			if (rst='1') then
				IR2 <= (others => '0');
			else
				IR2 <= IR1;
			end if;
		end if;
	end process;

	-- Update stack pointer
	-- If push: decrement
	-- If pop: increment
	--process(clk)
	--begin
	--	if rising_edge(clk) then
	--		if (rst='1') then
	--			SP <= (others => '0');
	--		elsif (IR1_op = iPOP) then
	--			SP <= SP + 1;
	--		elsif (IR1_op = iPUSH) then
	--			SP <= SP - 1;
	--		end if;
	--	end if;
	--end process;


end architecture;
