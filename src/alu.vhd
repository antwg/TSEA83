library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity ALU is
	port (
	MUX1: in unsigned(15 downto 0);
	MUX2 : in unsigned(15 downto 0);
	op_code : in unsigned(5 downto 0);
	result : out unsigned(15 downto 0);
	clk : in std_logic
	);	
end ALU;

architecture func of ALU is
signal Z, N, C, V, Z_sens, N_sens, C_sens, V_sens : unsigned(0 downto 0);
signal res_add : unsigned(31 downto 0);
signal res_sub : unsigned(31 downto 0);
signal send_through : unsigned(31 downto 0);
signal res_mul : unsigned(15 downto 0);
signal logical_and : unsigned(31 downto 0);
signal logical_or : unsigned(31 downto 0);
signal add_carry: unsigned(31 downto 0);
signal sub_carry: unsigned(31 downto 0);
signal log_shift_left: unsigned (31 downto 0);
signal log_shift_right: unsigned (31 downto 0);
signal result_large : unsigned(31 downto 0);
signal alu_op : unsigned(5 downto 0);



-- branch has not been fully implemented
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
constant I_AND		: unsigned(5 downto 0) := "010100";
constant ANDI		: unsigned(5 downto 0) := "010101";
constant I_OR		: unsigned(5 downto 0) := "010111";
constant ORI		: unsigned(5 downto 0) := "011000";
constant PUSH		: unsigned(5 downto 0) := "011001";
constant POP		: unsigned(5 downto 0) := "011010";
constant ADC		: unsigned(5 downto 0) := "011011"; 
constant SBC 		: unsigned(5 downto 0) := "011100";
constant MUL 		: unsigned(5 downto 0) := "011101";
constant MULI 		: unsigned(5 downto 0) := "011111";
constant MULS		: unsigned(5 downto 0) := "100000";
constant MULSI		: unsigned(5 downto 0) := "100001";
constant LSLS		: unsigned(5 downto 0) := "100010";
constant LSLR		: unsigned(5 downto 0) := "100011";
constant CMPI 		: unsigned(5 downto 0) := "100100";


constant alu_add	: unsigned(3 downto 0) := "001";
constant alu_sub	: unsigned(3 downto 0) := "010";
constant alu_cmp	: unsigned(3 downto 0) := "011";
constant alu_mul	: unsigned(3 downto 0) := "100";
constant alu_RS		: unsigned(3 downto 0) := "100";
constant alu_LS		: unsigned(3 downto 0) := "100";



begin

--ADD,ADDI,----------
res_add <= MUX1 + MUX2;
--ADC
add_carry <= MUX1 + MUX2 + C;
--- sub carry
sub_carry <= MUX1 - MUX2 - C;
---SUB,SUBI------
res_sub <= MUX1 - MUX2;
---Send through ----
--ldi, LD, STI, ST, COPY, 
send_through <= MUX2;
---mul---
--mul,muli,muls,mulsi
res_mul <= MUX1 * MUX2;
--built in multiplication, how to use? 
--and, andi--
logical_and <= MUX1 and MUX2;
--or, ori--
logical_or <= MUX1 or MUX2;
--shift left, LSLS
log_shift_left <= shift_left(unsigned(MUX1), 1);
--shift right, LSRS
log_shift_right <= shift_left(unsigned(MUX1), 1);


-- perform the operation
with op_code select result_large <=
	res_add	when ADD,
	res_add	when ADDI,
	add_carry when ADC,
	sub_carry when SBC,
	res_sub when SUB,
	res_sub when SUBI,
	res_mul when MUL,
	res_mul when MULI,
	res_mul when MULS,
	res_mul when MULSI,
	logical_and when I_AND,
	logical_or when I_OR,
	log_shift_left when LSLS,
	log_shift_right when LSLR,
	send_through when others;

	result <= result_large(15 downto 0);

-- choose alu_op code since several codes have the same operations
--makes using the alu simplier here but maybe creates an extra "unneccsary" mux
with op_code select alu_op <=
	-- 000 noop, 001 add, 010 sub, 011 cmp, 
	"000" when	NOP, 	
	"000" when RJMP,
	"000" when BEQ,		
	"000" when BNE, 	
	"000" when BPL, 	
	"000" when BMI, 	
	"000" when BGE, 	
	"000" when BLT, 	 
	"000" when LDI, 	
	"000" when LD,		
	"000" when STI, 	
	"000" when ST, 	
	"000" when COPY,						
	alu_add when ADD,	
	alu_add when ADDI, 
	alu_sub when SUB,	
	alu_sub when SUBI,
	alu_cmp when CMP,	
	"000" when I_AND,
	"000" when ANDI,
	"000" when I_OR,
	"000" when ORI	,
	"000" when PUSH,
	"000" when POP	,
	alu_add when ADC,		
	alu_sub when SBC, 	
	alu_mul when MUL ,
	alu_mul when MULI,
	alu_mul when MULS,
	alu_mul when MULSI,
	alu_LS when LSLS,
	alu_RS when LSLR,
	alu_cmp when CMPI,
	"000" when others;


	-- C flag	
process(clk)
begin
	if rising_edge(clk)	then
		case alu_op is
			when alu_add=> C(0) <= result_large(16);
			when alu_sub => C(0) <= result_large(16);
			when alu_LS => C(0) <= MUX1(15);
			when alu_RS => C (0)<= MUX1(0);
			when alu_mul => C(0) <= result_large(31);
			when others => C(0) <= '0';
			end case;
	end if;
end process;

	-- V flag	
process(clk)
begin
	if rising_edge(clk)	then
		case alu_op is
			when alu_add => V(0) <= ((MUX1(15) and MUX2(15) and not result_large(15))
			or (not MUX1(15) and not MUX2(15) and result_large(15)));
			
			when alu_sub => V(0) <= ((not MUX1(15) and MUX2(15) and result_large(15))
			or ( MUX1(15) and not MUX2(15) and not result_large(15)));
			when others => V(0) <= '0';
		end case;	
	end if;

end process;

	-- N flag	
process(clk)
begin
	if rising_edge(clk)	then
		case alu_add is
			when alu_add => N(0) <= result_large(15);
			when alu_sub => N(0) <= result_large(15);
			when alu_cmp => N(0) <= result_large(15);
			when alu_mul => N(0) <= result_large(31);
			when others => N(0) <= '0';
			end case;
	end if;

end process;

	-- Z flag	
process(clk)
begin
	if rising_edge(clk)	then
		case alu_op is
			-- when result is zero
			when alu_add => Z(0) <= ('1' when result_large(15 downto 0) = 0 else '0');
			when alu_sub => Z(0) <= ('1' when (result_large(15 downto 0) = 0) else '0');
			when alu_cmp => Z(0) <= ('1' when ((MUX1 and MUX2) = MUX1) else '0'); -- when there is no change
			when others => Z(0) <= '0';
			end case;
	end if;

end process;




end architecture;
