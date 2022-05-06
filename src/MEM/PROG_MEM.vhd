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
		x"00000000", --     nop
x"2300002E", --     subr SPAWN_AST
x"08000000", --     ldi a, 0
x"2300008F", --     subr MOVE_AST
x"2300000E", --     subr TENTH_TIMER
x"0100FFFE", --     rjmp START
x"17100000", --     push b
x"17200000", --     push c
x"081000F9", --     ldi b, 249
x"08200064", --     ldi c, 100
x"10100001", --     subi b, 1
x"0300FFFF", --     bne MS_TIMER_OUTER_LOOP
x"081000F9", --     ldi b, 249
x"10200001", --     subi c, 1
x"0300FFFC", --     bne MS_TIMER_OUTER_LOOP
x"18200000", --     pop c
x"18100000", --     pop b
x"24000000", --     ret
x"17100000", --     push b
x"08100064", --     ldi b, 100
x"2300FFF2", --     subr MS_TIMER
x"10100001", --     subi b, 1
x"0300FFFE", --     bne TENTH_TIMER_LOOP
x"18100000", --     pop b
x"24000000", --     ret
x"17100000", --     push b
x"081003E8", --     ldi b, 1000
x"2300FFEB", --     subr MS_TIMER
x"10100001", --     subi b, 1
x"0300FFFE", --     bne SEC_TIMER_LOOP
x"18100000", --     pop b
x"24000000", --     ret
x"17100000", --     push b
x"17200000", --     push c
x"17300000", --     push d
x"08103FAD", --     ldi b, 16301 ; Two large prime numbers
x"0820B465", --     ldi c, 46181
x"08300005", --     ldi d, 5
x"0D610000", --     add g, b
x"1D620000", --     muls g, c
x"10300001", --     subi d, 1
x"0300FFFD", --     bne RAND_NUM_GEN_LOOP
x"0C060000", --     copy a, g
x"18300000", --     pop d
x"18200000", --     pop c
x"18100000", --     pop b
x"24000000", --     ret
x"17300000", --     push d ; Random number
x"17400000", --     push e ; xpixel (8 low)
x"17500000", --     push f ; which sprite (3 high) and ypixel (8 low)
x"17000000", --     push a
x"2300FFED", --     subr RAND_NUM_GEN
x"0C300000", --     copy d, a
x"18000000", --     pop a
x"0C430000", --     copy e, d
x"14400003", --     andi e, $0003
x"12400000", --     cmpi e, 0
x"02000011", --     beq SPAWN_AST_LEFT
x"12400001", --     cmpi e, 1
x"0200000B", --     beq SPAWN_AST_RIGHT
x"12400002", --     cmpi e, 2
x"02000005", --     beq SPAWN_AST_BOTTOM
x"08400050", --     ldi e, 80           ; Xpixel = 80
x"08500000", --     ldi f, $0000        ; Ypixel = 0
x"08100003", --     ldi b, 3
x"0100000C", --     rjmp SPAWN_AST_END
x"08400050", --     ldi e, 80           ; Xpixel = 80
x"08500082", --     ldi f, 130          ; Ypixel = 130
x"08100001", --     ldi b, 1
x"01000008", --     rjmp SPAWN_AST_END
x"084000A2", --     ldi e, $00A2        ; Xpixel = 162
x"08500041", --     ldi f, 65          ; Ypixel = 65
x"08100002", --     ldi b, 2
x"01000004", --     rjmp SPAWN_AST_END
x"08400000", --     ldi e, 0            ; Xpixel = 0
x"08500041", --     ldi f, 65           ; Ypixel = 65
x"08100000", --     ldi b, 0
x"2300000E", --     subr GET_AST_SIZE   ; Get a random size of asteroid and apply
x"15510000", --     or f, b
x"1E000002", --     mulsi a, 2           ; Store xpixel
x"0830FC00", --     ldi d, $FC00
x"0D300000", --     add d, a
x"0B340000", --     st d, e
x"0830FC01", --     ldi d, $FC01        ; Store ypixel and asteroid type
x"0D300000", --     add d, a
x"0B350000", --     st d, f
x"23000019", --     subr SET_AST_DIR
x"18500000", --     pop f
x"18400000", --     pop e
x"18300000", --     pop d
x"24000000", --     ret
x"17200000", --     push c
x"17000000", --     push a             
x"2300FFC3", --     subr RAND_NUM_GEN
x"0C200000", --     copy c, a
x"18000000", --     pop a
x"14000003", --     andi a, $0003
x"12000000", --     cmpi a, 0
x"02000009", --     beq GET_AST_SIZE_LARGE
x"12000001", --     cmpi a, 1
x"02000005", --     beq GET_AST_SIZE_MEDIUM
x"12000002", --     cmpi a, 2
x"02000001", --     beq GET_AST_SIZE_SMALL
x"08108000", --     ldi b, $8000
x"01000005", --     rjmp GET_AST_SIZE_END
x"08106000", --     ldi b, $6000
x"01000003", --     rjmp GET_AST_SIZE_END
x"08104000", --     ldi b, $4000
x"01000001", --     rjmp GET_AST_SIZE_END
x"18200000", --     pop c
x"24000000", --     ret
x"17200000", --     push c
x"17300000", --     push d
x"17400000", --     push e
x"082000F0", --     ldi c, $00F0
x"083000F1", --     ldi d, $00F1
x"1F000000", --     lsls a          ; Mult by 2
x"0D200000", --     add c, a
x"0D300000", --     add d, a
x"20000000", --     lsrs a          ; Reset
x"12100000", --     cmpi b, 0               ; Right 
x"02000009", --     beq SET_AST_DIR_RIGHT
x"12100001", --     cmpi b, 1               ; Up
x"0200000F", --     beq SET_AST_DIR_UP
x"12100002", --     cmpi b, 2               ; Left
x"02000009", --     beq SET_AST_DIR_LEFT
x"08400000", --     ldi e, 0        ; x-dir
x"0B240000", --     st c, e
x"08400001", --     ldi e, 1        ; y-dir
x"0B340000", --     st d, e 
x"08400001", --     ldi e, 1        ; x-dir
x"0B240000", --     st c, e
x"08400000", --     ldi e, 0        ; y-dir
x"0B340000", --     st d, e
x"0840FFFF", --     ldi e, -1        ; x-dir
x"0B240000", --     st c, e
x"08400000", --     ldi e, 0        ; y-dir
x"0B340000", --     st d, e
x"08400000", --     ldi e, 0        ; x-dir
x"0B240000", --     st c, e
x"0840FFFF", --     ldi e, -1        ; y-dir
x"0B340000", --     st d, e
x"18400000", --     pop e
x"18300000", --     pop d
x"18200000", --     pop c
x"24000000", --     ret
x"17200000", --     push c
x"17300000", --     push d
x"17400000", --     push e
x"17500000", --     push f
x"17600000", --     push g
x"17700000", --     push h
x"082000F0", --     ldi c, $00F0
x"083000F1", --     ldi d, $00F1
x"1F000000", --     lsls a          ; Mult by 2
x"0D200000", --     add c, a
x"0D300000", --     add d, a
x"09420000", --     ld e, c         ; Move in x-dir
x"09530000", --     ld f, d         ; Move in y-dir
x"0820FC00", --     ldi c, $FC00
x"0830FC01", --     ldi d, $FC01
x"0D200000", --     add c, a
x"0D300000", --     add d, a
x"09620000", --     ld g, c         ; Curr x-pos
x"09730000", --     ld h, d         ; Curr y-pos
x"0D640000", --     add g, e        ; New x-pos
x"0D730000", --     add h, d        ; New y-pos
x"0B260000", --     st c, g
x"0B370000", --     st d, h
x"20000000", --     lsrs a
x"18700000", --     pop h
x"18600000", --     pop g
x"18500000", --     pop f
x"18400000", --     pop e
x"18300000", --     pop d
x"18200000", --     pop c
x"24000000", --     ret
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
