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

signal IR1 : unsigned(25 downto 0); -- Fetch stage
alias IR1_op : unsigned(5 downto 0) is IR1(25 downto 20);
alias IR1_rd : unsigned(3 downto 0) is IR1(19 downto 16);
alias IR1_ra : unsigned(3 downto 0) is IR1(15 downto 12);
alias IR1_const : unsigned(11 downto 0) is IR1(11 downto 0);

signal IR2 : unsigned(25 downto 0); -- Decode stage
alias IR2_op : unsigned(5 downto 0) is IR2(25 downto 20);
alias IR2_rd : unsigned(3 downto 0) is IR2(19 downto 16);
alias IR2_ra : unsigned(3 downto 0) is IR2(15 downto 12);
alias IR2_const : unsigned(11 downto 0) is IR2(11 downto 0);

-- Stack pointer
signal SP : unsigned(15 downto 0);

signal status_reg : unsigned(4 downto 0);
alias ZF : std_logic is status_reg(0);
alias NF : std_logic is status_reg(1);
alias CF : std_logic is status_reg(2);
alias vF : std_logic is status_reg(3);
--alias ZF : std_logic is status_reg(4);

signal PC, PC1, PC2 : unsigned(15 downto 0);

signal PMdata_out : unsigned(25 downto 0);
signal pm_addr : unsigned(15 downto 0);

-- Data memory
signal dm_addr : unsigned(15 downto 0);
signal dm_we : std_logic;
signal dm_data_out : unsigned(15 downto 0);
signal dm_data_in : unsigned(15 downto 0);

-- Sprite memory
signal sm_addr : unsigned(15 downto 0);
signal sm_we : std_logic;

signal alu_out : unsigned(15 downto 0);

signal data_bus : unsigned(15 downto 0);

-- Register file
signal rf_we : std_logic;

signal ALU_dummy1 : unsigned(15 downto 0);
signal ALU_dummy2 : unsigned(15 downto 0);

-- Instructions
constant iNOP : unsigned(5 downto 0) := "000000";
constant iJ 	: unsigned(5 downto 0) := "010101";
constant iBF 	: unsigned(5 downto 0) := "000100";
constant iPUSH 	: unsigned(5 downto 0) := "000111"; -- TODO change op code
constant iPOP 	: unsigned(5 downto 0) := "000110";

component PROG_MEM is
	port(
		addr : in unsigned(15 downto 0);
		data_out : out unsigned(25 downto 0)
		);
end component;

component DATA_MEM is
	port(
		addr : in unsigned(15 downto 0);
		data_out : out unsigned(15 downto 0);
		data_in : in unsigned(15 downto 0);
		we : in std_logic; -- write enable
		clk : in std_logic
		);
end component;

-- Sprite minne
-- address
-- we

component REG_FILE is
	port(
    rd : in unsigned(3 downto 0);
    rd_out : out unsigned(15 downto 0);
    ra : in unsigned(3 downto 0);
		ra_out : out unsigned(15 downto 0);
		we : in std_logic; -- write enable
		data_in : in unsigned(15 downto 0);
		clk : std_logic
		);
end component;

begin

	U1 : PROG_MEM port map(
		addr => pm_addr,
		data_out => PMdata_out
	);

	U2 : REG_FILE port map(
		rd => IR2_rd,
		ra => IR2_ra,
		rd_out => ALU_dummy1,
		ra_out => ALU_dummy2,
		we => rf_we,
		data_in => data_bus,
		clk => clk
	);

	U3 : DATA_MEM port map(
			addr => dm_addr,
			we => dm_we,
			data_out => dm_data_out,
			data_in => dm_data_in,
			clk => clk
	);

	-- Address controller
	process(clk)
	begin
		if rising_edge(clk) then
			if (rst='1') then
				dm_addr <= (others => '0');
				sm_addr <= (others => '0');
				dm_we <= '0';
				sm_we <= '0';
			elsif (alu_out <= x"FC00") then
				dm_addr <= alu_out;
				dm_we <= '1';
			else
				sm_addr <= (alu_out and "0000001111111111"); -- translate to sm_addr
				sm_we <= '1';
			end if;
		end if;
	end process;

	-- If jmp instruction, take value from IR2, else increment
	process(clk)
	begin
		if rising_edge(clk) then
			if (rst='1') then
				PC <= (others => '0');
			elsif (IR2_op = iJ) then
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
			elsif (IR2_op = iJ) then
				IR1_op <= iNOP;
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
	process(clk)
	begin
		if rising_edge(clk) then
			if (rst='1') then
				SP <= (others => '0');
			elsif (IR1_op = iPOP) then
				SP <= SP + 1;
			elsif (IR1_op = iPUSH) then
				SP <= SP - 1;
			end if;
		end if;
	end process;


end architecture;
