library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity pipeCPU is
	port (
		clk : in std_logic;
		rst : in std_logic;
		UART_in : in std_logic;
		--UART_out : out std_logic;
		seg : out unsigned(7 downto 0);
		an : out unsigned(3 downto 0));
end pipeCPU;

architecture func of pipeCPU is

----------------------------- Internal signals --------------------------------
signal IR1 : unsigned(31 downto 0); -- Fetch stage
alias IR1_op : unsigned(7 downto 0) is IR1(31 downto 24);
alias IR1_rd : unsigned(3 downto 0) is IR1(23 downto 20);
alias IR1_ra : unsigned(3 downto 0) is IR1(19 downto 16);
alias IR1_const : unsigned(15 downto 0) is IR1(15 downto 0);

signal IR2 : unsigned(31 downto 0); -- Decode stage
alias IR2_op : unsigned(7 downto 0) is IR2(31 downto 24);
alias IR2_rd : unsigned(3 downto 0) is IR2(23 downto 20);
alias IR2_ra : unsigned(3 downto 0) is IR2(19 downto 16);
alias IR2_const : unsigned(15 downto 0) is IR2(15 downto 0);

-- Stack pointer
signal SP : unsigned(15 downto 0);

-- Status register
signal status_reg_out : unsigned(3 downto 0);
alias ZF : std_logic is status_reg_out(0);
alias NF : std_logic is status_reg_out(1);
alias CF : std_logic is status_reg_out(2);
alias VF : std_logic is status_reg_out(3);

signal PC, PC1, PC2 : unsigned(15 downto 0);

signal PMdata_out : unsigned(31 downto 0);
signal pm_addr : unsigned(15 downto 0);

-- Data memory
signal dm_addr, dm_data_out : unsigned(15 downto 0);
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

-- Loader signals (testing // Rw)
signal temp_done : std_logic;
signal loader_done : std_logic;
signal loader_we : std_logic;
signal loader_addr : unsigned(15 downto 0);
signal loader_data_Out : unsigned(31 downto 0);

-- Out to 7seg
signal led_value : unsigned(15 downto 0);

-- Instructions
constant NOP 		: unsigned(7 downto 0) := x"00";
constant RJMP		: unsigned(7 downto 0) := x"01";
constant BEQ		: unsigned(7 downto 0) := x"02";
constant BNE 		: unsigned(7 downto 0) := x"03";
constant BPL 		: unsigned(7 downto 0) := x"04";
constant BMI 		: unsigned(7 downto 0) := x"05";
constant BGE 		: unsigned(7 downto 0) := x"06";
constant BLT 		: unsigned(7 downto 0) := x"07";
constant LDI 		: unsigned(7 downto 0) := x"08";
constant LD 		: unsigned(7 downto 0) := x"09";
constant STI 		: unsigned(7 downto 0) := x"0A";
constant ST  		: unsigned(7 downto 0) := x"0B";
constant COPY		: unsigned(7 downto 0) := x"0C";
constant ADD		: unsigned(7 downto 0) := x"0D";
constant ADDI		: unsigned(7 downto 0) := x"0E";
constant SUB		: unsigned(7 downto 0) := x"0F";
constant SUBI		: unsigned(7 downto 0) := x"10";
constant CMP		: unsigned(7 downto 0) := x"11";
constant CMPI		: unsigned(7 downto 0) := x"12";
constant I_AND		: unsigned(7 downto 0) := x"13";
constant ANDI		: unsigned(7 downto 0) := x"14";
constant I_OR		: unsigned(7 downto 0) := x"15";
constant ORI		: unsigned(7 downto 0) := x"16";
constant PUSH		: unsigned(7 downto 0) := x"17";
constant POP		: unsigned(7 downto 0) := x"18";
constant ADC		: unsigned(7 downto 0) := x"19";
constant SBC 		: unsigned(7 downto 0) := x"1A";
constant MUL 		: unsigned(7 downto 0) := x"1B";
constant MULI 		: unsigned(7 downto 0) := x"1C";
constant MULS		: unsigned(7 downto 0) := x"1D";
constant MULSI		: unsigned(7 downto 0) := x"1E";
constant LSLS		: unsigned(7 downto 0) := x"1F";
constant LSLR		: unsigned(7 downto 0) := x"20";


------------------------------------ Def components ---------------------------

component PROG_MEM is
    port( 
        clk : in std_logic;
        we : std_logic;
        addr : in unsigned(15 downto 0);
		data_out : out unsigned(31 downto 0);
	    wr_addr : in unsigned(15 downto 0);
	    wr_data : in unsigned(31 downto 0));
end component;

component PROG_LOADER is
	port( clk, rst, rx : in std_logic;
          done, we : out std_logic;
          addr : out unsigned(15 downto 0);
          data_out : out unsigned(31 downto 0));
end component;

component DATA_MEM is
	port( clk : in std_logic;
	      we : in std_logic; -- write enable
          data_in : in unsigned(15 downto 0);
          addr : in unsigned(15 downto 0);
	      data_out : out unsigned(15 downto 0));
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
		op_code : in unsigned(7 downto 0);
		result : out unsigned(15 downto 0);
		status_reg : out unsigned(3 downto 0);
		clk : in std_logic	
		);
end component;

component leddriver is
	Port ( clk,rst : in  STD_LOGIC;
           seg : out  UNSIGNED(7 downto 0);
           an : out  UNSIGNED (3 downto 0);
           value : in  UNSIGNED (15 downto 0));
	end component;

begin

------------------------------------ Components -------------------------------

	prog_mem_comp : PROG_MEM port map(
		clk => clk,
		addr => pm_addr,
		data_out => PMdata_out,
		we => loader_we,
		wr_addr => loader_addr,
		wr_data => loader_data_out
	);

	prog_loader_comp : PROG_LOADER port map(
		clk => clk,
		rst => rst,
	 	rx => UART_in,
		done => loader_done,
	  	we => loader_we,
	  	addr => loader_addr,
	  	data_out => loader_data_out
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
		we => dm_we,
		addr => dm_addr,
		data_out => dm_data_out,
		data_in => data_bus,
		clk => clk
	);

	alu_comp : ALU port map(
		MUX1 => alu_mux1,
		MUX2 => alu_mux2,
		op_code => IR2_op,
		result => alu_out,
		status_reg => status_reg_out,
		clk => clk
	);

	leddriver_comp : leddriver port map(
		clk => clk, rst => rst, seg => seg, an => an, value => led_value
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
								rf_out2 when (IR2_op = COPY or IR2_op = ST) else
								dm_data_out when (IR2_op = LD) else
								alu_out;

	-- Address controller
	dm_addr <= (alu_out and "0000000001111111");
	dm_we <= '1' when ((alu_out < x"FC00") and ((IR2_op = STI) or (IR2_op = ST))) else '0';
	led_value <= IR2_const;

	sm_addr <= (alu_out and "0000001111111111");
	sm_we <= '0' when (alu_out < x"FC00") else '1';

    	temp_done <= '1' when loader_done='0' else '0';

	-- Write enable RF
	rf_we <= '0' when ((IR2_op = NOP) or (IR2_op = RJMP) or (IR2_op = BEQ) or (IR2_op = BNE) or (IR2_op = BPL) or (IR2_op = BMI) or (IR2_op = BGE) or (IR2_op = BLT) or (IR2_op = STI) or (IR2_op = ST) or (IR2_op = PUSH)) else '1';

	-- If jmp or branch instruction, take value from PC2, else increment
	process(clk)
	begin
		if (rising_edge(clk)) then
			if (rst='1') then
				PC <= (others => '0');
            elsif (temp_done = '1' and rst='0') then
                if ((IR2_op = RJMP) or
                       (IR2_op = BEQ and ZF = '1') or
                       (IR2_op = BNE and ZF = '0') or
                       (IR2_op = BPL and NF = '0') or
                       (IR2_op = BMI and NF = '1') or
                       (IR2_op = BGE and (NF xor VF) = '0') or
                       (IR2_op = BLT and (NF xor VF) = '1')) then
                    PC <= PC2;
                else
                    PC <= PC + 1;
                end if;
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
				-- TODO Add for branches?
				IR1_op <= NOP;
			else
				IR1 <= PMdata_out(31 downto 0);
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
