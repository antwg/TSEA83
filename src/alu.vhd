library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity ALU is
	port (
	MUX1: in unsigned(15 downto 0);
	MUX2 : in unsigned(15 downto 0);
	op_code : in unsigned(7 downto 0);
	result : out unsigned(15 downto 0);
	status_reg : out unsigned(3 downto 0);
	reset : in std_logic;
	clk : in std_logic
	);	
end ALU;

architecture func of ALU is
signal status_reg_out : unsigned(3 downto 0) := (others => '0');
alias Z :std_logic is status_reg_out(0);
alias N :std_logic is status_reg_out(1);
alias C :std_logic is status_reg_out(2);
alias V :std_logic is status_reg_out(3);
signal res_add : unsigned(31 downto 0)  := (others => '0');
signal res_sub : unsigned(31 downto 0) := (others => '0');
signal send_through : unsigned(31 downto 0) := (others => '0');
signal res_mul : unsigned(31 downto 0) := (others => '0');
signal res_muls : unsigned(31 downto 0) := (others => '0');
signal logical_and : unsigned(31 downto 0) := (others => '0');
signal logical_or : unsigned(31 downto 0) := (others => '0');
signal add_carry: unsigned(31 downto 0) := (others => '0');
signal sub_carry: unsigned(31 downto 0) := (others => '0');
signal log_shift_left: unsigned (31 downto 0) := (others => '0');
signal log_shift_right: unsigned (31 downto 0) := (others => '0');
signal result_large : unsigned(31 downto 0) := (others => '0');
signal alu_op : unsigned(3 downto 0) := (others => '0');


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


constant alu_add	: unsigned(3 downto 0) := "0001";
constant alu_sub	: unsigned(3 downto 0) := "0010";
constant alu_cmp	: unsigned(3 downto 0) := "0011";
constant alu_mul	: unsigned(3 downto 0) := "0100";
constant alu_muls	: unsigned(3 downto 0) := "0111";
constant alu_RS		: unsigned(3 downto 0) := "0101";
constant alu_LS		: unsigned(3 downto 0) := "0110";
constant alu_and	: unsigned(3 downto 0) := "1000";
constant alu_or		: unsigned(3 downto 0) := "1001";
constant alu_nop	: unsigned(3 downto 0) := "0000";
constant alu_add_carry	: unsigned(3 downto 0) := "1010";
constant alu_sub_carry	: unsigned(3 downto 0) := "1011";

begin
	
process(alu_op, MUX1, MUX2, status_reg_out)
begin
	result_large <= (others => '0');
	case alu_op is
	--	when alu_add 	    => result_large <= x"000"&((x"0"&MUX1) + (x"0"&MUX2));  
	--	when alu_add_carry 	=> result_large <= x"000"&((x"0"&MUX1) + (x"0"&MUX2) + (""&C));
	--	when alu_sub	    => result_large <= x"000"&((x"0"&MUX1) - (x"0"&MUX2));
	--	when alu_sub_carry	=> result_large <= x"000"&((x"0"&MUX1) - (x"0"&MUX2) - (""&C));
	--	when alu_and    	=> result_large <= x"0000"&(MUX1 and MUX2);
	--	when alu_or	        => result_large <= x"0000"&(MUX1 or MUX2);
	--	when alu_LS	        => result_large <= x"0000"&shift_left(unsigned(MUX1), 1);
	--	when alu_RS	        => result_large <= x"0000"&shift_right(unsigned(MUX1), 1);

        -- Only the following two cases breaks the CPU when jump NOP is set to 1234 at the end...
	--	when alu_mul    	=> result_large <= MUX1 * MUX2;
	--	when alu_muls   	=> result_large <= unsigned(signed(MUX1) * signed(MUX2));
		when others         => result_large <= (x"0000" & MUX2);
	end case;
end process;

status_reg <= status_reg_out;
result <= result_large(15 downto 0);

-- choose alu_op code since several codes have the same operations
--makes using the alu simplier here but maybe creates an extra "unneccsary" mux
with op_code select alu_op <=
	-- 000 noop, 001 add, 010 sub, 011 cmp, 
	alu_add         when ADD,	
	alu_add         when ADDI, 
	alu_add_carry   when ADC,
	alu_sub         when SUB,	
	alu_sub         when SUBI,
	alu_sub_carry   when SBC, 	
	alu_and         when I_AND,
	alu_and         when ANDI,
	alu_or          when I_OR,
	alu_or          when ORI,
	alu_mul         when MUL ,
	alu_mul         when MULI,
	alu_muls        when MULS,
	alu_muls        when MULSI,
	alu_LS          when LSLS,
	alu_RS          when LSLR,
	alu_cmp         when CMPI,
	alu_cmp         when CMP,
    alu_nop         when others;


	-- C flag
process(clk)
begin
	if rising_edge(clk)	then
		if reset = '1' then
			C <= '0';
		else
			case alu_op is
				when alu_add=> C <= result_large(16);
				when alu_sub => C <= result_large(16);
				when alu_LS => C <= MUX1(15);
				when alu_RS => C<= MUX1(0);
				when alu_mul => C <= result_large(31);
				when alu_muls => C <= result_large(31);
				when others =>  C <= '0';
			end case;
		end if;
	end if;
end process;

	-- V flag
process(clk)
begin
	if rising_edge(clk)	then
		if reset = '1' then
			V <= '0';
		else
			case alu_op is
				when alu_add => V <= ((MUX1(15) and MUX2(15) and not result_large(15))
				or (not MUX1(15) and not MUX2(15) and result_large(15)));
				
				when alu_sub => V <= ((not MUX1(15) and MUX2(15) and result_large(15))
				or ( MUX1(15) and not MUX2(15) and not result_large(15)));
				when others => V <= '0';
			end case;	
		end if;
	end if;

end process;

	-- N flag
process(clk)
begin
	if rising_edge(clk)	then
		if reset = '1' then
			N <= '0';
		elsif (alu_op /= alu_nop) then	--if it is an actual alu operation
			case alu_op is
				when alu_add => N <= result_large(15);
				when alu_sub => N <= result_large(15);
				when alu_cmp => N <= result_large(15);
				when alu_mul => N <= result_large(31);
				when alu_muls => N <= result_large(31);
				when others => N <= '0';
			end case;
		end if;
	end if;

end process;

	-- Z flag
process(clk)
begin
	if rising_edge(clk)	then
		if reset = '1' then
			Z <= '0';
		elsif (alu_op = alu_cmp) then
			if ((MUX1 - MUX2) = 0) then
				Z <= '1';
			else 
				Z <= '0';
			end if;
		elsif (alu_op /= alu_nop) then
			if (result_large(15 downto 0) = 0) then
				Z <= '1';
			else 
				Z <= '0';
			end if;
		end if;
	end if;	

end process;




end architecture;
