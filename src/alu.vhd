library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity ALU is
	port (
	MUX1: in unsigned(15 downto 0);
	MUX2 : in unsigned(15 downto 0);
	op_code : in unsigned(7 downto 0);
	result : out unsigned(15 downto 0);
	clk : in std_logic
	);	
end ALU;

architecture func of ALU is

signal Z, N, C, V, Z_sens, N_sens, C_sens, V_sens : unsigned(0 downto 0);
signal res_add : unsigned(31 downto 0);
signal res_sub : unsigned(31 downto 0);
signal send_through : unsigned(31 downto 0);
signal res_mul : unsigned(31 downto 0);
signal logical_and : unsigned(31 downto 0);
signal logical_or : unsigned(31 downto 0);
signal add_carry: unsigned(31 downto 0);
signal sub_carry: unsigned(31 downto 0);
signal log_shift_left: unsigned (31 downto 0);
signal log_shift_right: unsigned (31 downto 0);
signal result_large : unsigned(31 downto 0);
signal alu_op : unsigned(2 downto 0);



-- branch has not been fully implemented
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


constant alu_add	: unsigned(2 downto 0) := "001";
constant alu_sub	: unsigned(2 downto 0) := "010";
constant alu_cmp	: unsigned(2 downto 0) := "011";
constant alu_mul	: unsigned(2 downto 0) := "100";
constant alu_RS		: unsigned(2 downto 0) := "101";
constant alu_LS		: unsigned(2 downto 0) := "110";



begin

--ADD,ADDI,----------
res_add <= x"000"&((x"0"&MUX1) + (x"0"&MUX2));
--ADC
add_carry <= x"000"&((x"0"&MUX1) + (x"0"&MUX2) + C);
--- sub carry
sub_carry <= x"000"&((x"0"&MUX1) - (x"0"&MUX2) - C);
---SUB,SUBI------
res_sub <= x"000"&((x"0"&MUX1) - (x"0"&MUX2));
---Send through ----
--ldi, LD, STI, ST, COPY,
send_through <= x"0000"&MUX2;
---mul---
--mul,muli,muls,mulsi
res_mul <= MUX1 * MUX2;
--built in multiplication, how to use? 
--and, andi--
logical_and <= x"0000"&(MUX1 and MUX2);
--or, ori--
logical_or <= x"0000"&(MUX1 or MUX2);
--shift left, LSLS
log_shift_left <= x"0000"&shift_left(unsigned(MUX1), 1);
--shift right, LSRS
log_shift_right <= x"0000"&shift_right(unsigned(MUX1), 1);


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
			when alu_RS => C(0)<= MUX1(0);
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
		if (alu_op = alu_add or alu_op = alu_sub or alu_op = alu_mul) then
			if (result_large(15 downto 0) = 0) then
				Z <= "1";
			else 
				Z <= "0";
			end if;

		elsif (alu_op = alu_cmp) then
			if ((MUX1 and MUX2) = MUX1) then
				Z <= "1";
			else 
				Z <= "0";
			end if;
		end if;
	end if;	

end process;




end architecture;
