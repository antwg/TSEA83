library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity ALU is
	port (
	MUX1: in unsigned(15 downto 0);
	MUX2 : in unsigned(15 downto 0);
	op_code : in unsigned(5 downto 0);
	result : out unsigned(15 downto 0);
end ALU;

architecture func of ALU is
signal Z, N, C, V, Z_sens, N_sens, C_sens, V_sens : std_logic;
signal add : unsigned(15 downto 0);
signal addi : unsigned(15 downto 0);
signal subi : unsigned(15 downto 0);
signal send_through : unsigned(15 downto 0);
signal mul : unsigned(15 downto 0);
signal logical_and : unsigned(15 downto 0);
signal logical_or : unsigned(15 downto 0);
signal add_carry: unsigned(15 downto 0);
signal sub_carry: unsigned(15 downto 0);
signal log_shift_left: unsigned (15 downto 0);
signal log_shift_right: unsigned (15 downto 0);
signal result_large : unsiged(31 downto 0)
	
constant NOP 		: unsigned(5 downto 0) := "000000" 
constant RJMP		: unsigned(5 downto 0) := "000001"
constant BEQ		: unsigned(5 downto 0) := "000010"
constant BNE 		: unsigned(5 downto 0) := "000011"
constant BPL 		: unsigned(5 downto 0) := "000100"
constant BMI 		: unsigned(5 downto 0) := "000101"
constant BGE 		: unsigned(5 downto 0) := "000111"
constant BLT 		: unsigned(5 downto 0) := "001000"   
constant LDI 		: unsigned(5 downto 0) := "001001"
constant LD 		: unsigned(5 downto 0) := "001010"
constant STI 		: unsigned(5 downto 0) := "001011"
constant ST  		: unsigned(5 downto 0) := "001100"
constant COPY		: unsigned(5 downto 0) := "001101"
constant ADD		: unsigned(5 downto 0) := "001111"
constant ADDI		: unsigned(5 downto 0) := "010000"
constant SUB		: unsigned(5 downto 0) := "010001"
constant SUBI		: unsigned(5 downto 0) := "010010"
constant CMP		: unsigned(5 downto 0) := "010011"
constant _AND		: unsigned(5 downto 0) := "010100"
constant ANDI		: unsigned(5 downto 0) := "010101"
constant _OR		: unsigned(5 downto 0) := "010111"
constant ORI		: unsigned(5 downto 0) := "011000"
constant PUSH		: unsigned(5 downto 0) := "011001"
constant POP		: unsigned(5 downto 0) := "011010"
constant ADC		: unsigned(5 downto 0) := "011011"
constant SBC 		: unsigned(5 downto 0) := "011100"
constant MUL 		: unsigned(5 downto 0) := "011101"
constant MULI 		: unsigned(5 downto 0) := "011111"
constant MULS		: unsigned(5 downto 0) := "100000"
constant MULSI		: unsigned(5 downto 0) := "100001"
constant LSLS		: unsigned(5 downto 0) := "100010"
constant LSLR		: unsigned(5 downto 0) := "100011"


begin

--ADD,ADDI,----------
add <= MUX1 + MUX2;
--ADC
add_carry <= MUX1 + MUX2 + 1;
--- sub carry
sub_carry <= MUX1 - MUX2 - 1;
---SUB,SUBI------
sub <= MUX1 - MUX2;
---Send through ----
--ldi, LD, STI, ST, COPY, 
send_through <= MUX2;
---mul---
--mul,muli,muls,mulsi
mul <= MUX1 * MUX2;
--built in multiplication, how to use? 
--and, andi--
logical_and <= MUX1 and MUX2;
--or, ori--
logical_or <= MUX1 or MUX2;
--shift left, LSLS
log_shift_left <= shift_left(unsigned(MUX1), 1);
--shift right, LSRS
log_shift_right <= shift_left(unsigned(MUX1), 1);


--decide OP code for all operations
with op_code select result <=
	add	when ADD,
	add	when ADDI,
	add_carry when ADC,
	sub_carry when SBC
	sub when SUB
	sub when SUBI 
	mul when MUL,
	mul when MULI,
	mul when MULS,
	mul when MULSI,
	logical_and when _AND,
	logical_or when _OR,
	log_shift_left when LSLS,
	log_shift_right when LSRS,
	send_through when others;
end case;

	-- C flag	
process(clk)
begin
	if rising_edge(clk)	then
		case op_code is
			when ADD => C <= result_large(16);
			when ADDI => C <= result_large(16);
		end case;
	end if;

end process

	-- V flag	
process(clk)
begin
	if rising_edge(clk)	then
		case op_code is
			when ADD => C <= result_large(16);
			when ADDI => C <= result_large(16);
			when ADD => C <= result_large(16);
		end case;
	end if;

end process

	-- N flag	
process(clk)
begin
	if rising_edge(clk)	then
		case op_code is
			when ADD => N <= result_large(15);

			end case;
	end if;

end process

	-- Z flag	
process(clk)
begin
	if rising_edge(clk)	then
		case op_code is
			-- when result is zero
			ADD => Z <= '1' when R(result_large(15 downto 0)) else '0'
			SUB => Z <= '1' when R(result_large(15 downto 0)) else '0'
			
			end case;
	end if;

end process




end architecture;
