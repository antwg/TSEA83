library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity PROG_MEM is
	Port( 	clk, we : in std_logic;
            addr : in unsigned(15 downto 0);
		    data_out : out unsigned(31 downto 0);
		    wr_addr : in unsigned(15 downto 0);
		    wr_data : in unsigned(31 downto 0));
end PROG_MEM;

architecture func of PROG_MEM is

	type PM_t is array(0 to 1024) of unsigned(31 downto 0);
	constant PM_c : PM_t := (


    x"21000000", --     pusr
    x"0800000A", --     ldi a, 10
    x"08100004", --     ldi b, 4
    x"0F010000", --     sub a, b        ; a = 6
    x"0E000002", --     addi a, 2       ; a = 8
    x"10100002", --     subi b, 2       ; b = 2
    x"0D010000", --     add a, b        ; a = 10
    x"20000000", --     lsrs a          ; a = 5
    x"1C000003", --     muli, a, 3      ; a = 15
    x"1F100000", --     lsls b          ; b = 4
    x"1B010000", --     mul a, b        ; a = 60
    x"1E00FFFF", --     mulsi a, -1     ; a = -60 
    x"0B100000", --     st b, a         ; store a = -60 on addr b = 4
    x"08000000", --     ldi a, 0        ; a = 0
    x"09010000", --     ld a, b         ; a = -60
    x"14000007", --     andi a, 7       ; a = 4
    x"08100008", --     ldi b, 8
    x"15010000", --     or a, b         ; a = 12  
    x"16000010", --     ori a, 16       ; a = 28
    x"13010000", --     and a, b        ; a = 8
    x"1D000000", --     muls a, a       ; a = 64
    x"12000040", --     cmpi a, 64
    x"02000002", --     beq 2           ; Should branch
    x"08000000", --     ldi a, 0
    x"0E000006", --     addi a, 6       ; a = 70
    x"1200003F", --     cmpi a, 63 
    x"02000002", --     beq 2           ; should not branch
    x"0E000002", --     addi 2          ; a = 72
    x"12000002", --     cmpi a, 2 
    x"03000002", --     bne 2           ; should branch
    x"08000000", --     ldi a, 0
    x"11000000", --     cmp a, a 
    x"03000002", --     bne 2           ; should not branch
    x"0E000002", --     addi a, 2       ; a = 74
    x"12000001", --     cmpi a, 1
    x"04000002", --     bpl 2           ; should branch
    x"08000000", --     ldi a, 0
    x"12000064", --     cmpi a, 100
    x"04000002", --     bpl 2           ; should not branch
    x"0E000002", --     addi a, 2       ; a = 76
    x"12000064", --     cmpi a, 100
    x"05000002", --     bmi 2           ; should branch
    x"08000000", --     ldi a, 0
    x"12000001", --     cmpi a, 1
    x"05000002", --     bmi 2           ; should not branch
    x"0E000002", --     addi a, 2       ; a = 78
    x"1200000A", --     cmpi a, 10      
    x"06000002", --     bge 2           ; should branch
    x"08000000", --     ldi a, 0
    x"11000000", --     cmp a, a 
    x"06000002", --     bge 2           ; should branch
    x"08000000", --     ldi a, 0
    x"12000064", --     cmpi a, 100     
    x"06000002", --     bge 2           ; should not branch
    x"0E000002", --     addi a, 2       ; a = 80
    x"12000064", --     cmpi a, 100
    x"07000002", --     blt 2           ; should branch
    x"08000000", --     ldi a, 0
    x"11000000", --     cmp a, a 
    x"07000002", --     blt 2           ; should not branch
    x"0E000002", --     addi a, 2       ; a = 82
    x"12000004", --     cmpi a, 4
    x"07000002", --     blt 2           ; should not branch
    x"0E000002", --     addi a, 2       ; a = 84
    x"20000000", --     lsrs a          ; a = 42
    x"20000000", --     lsrs a          ; a = 21
    x"10000010", --     subi a, 16      ; a = 5
    x"0810000A", --     ldi b, 10
    x"17000000", --     push a
    x"17100000", --     push b
    x"08000000", --     ldi a, 0
    x"18100000", --     pop b
    x"18000000", --     pop a
    x"11000000", --     cmp a,a
    x"22000000", --     posr
    x"00000000", --     nop
    x"0100FFFF", --     rjmp LOOP
    
    --x"08000001", --     ldi a, 1
    --x"10000001", --     subi a, 1
    --x"12000000", --     cmpi a, 0
    --x"23000005", --     subr TEST
    --x"02000002", --     beq FINISH
    --x"08001337", --     ldi a, $1337
    --x"00000000", --     nop
    --x"0100FFFF", --     rjmp -1
    --x"08100000", --     ldi b, 0
    --x"10100001", --     subi b, 1
    --x"24000000", --     ret
    
      
  
  
  --x"08000000", -- ldi a,$0000
        --x"0E000001", --     addi a,1
        --x"23000002", --     subr WAIT
        --x"0100FFFE", --     rjmp COUNTER
        --x"0830FFFF", --     ldi d,$FFFF
        --x"10300001", --     subi d,1
        --x"0300FFFF", --     bne WAIT_LOOP
        --x"24000000", --     ret
        --x"08001337", --     ldi a,$1337
        --x"00000000", --     nop
        --x"0100FFFF", --     rjmp -1

	    others => (others => '0')
	);

	signal PM : PM_t := PM_c;

begin
  	process(clk)
        begin
          if rising_edge(clk) then
            if we = '1' then
              PM(to_integer(wr_addr)) <= wr_data;
            end if;
          end if;
  	end process;

	data_out <= PM(to_integer(addr)); -- much hardware with asyn read, same in DM
end func;
