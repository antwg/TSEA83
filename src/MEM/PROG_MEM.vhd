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
        -- labels_and_subroutines.asm
        x"08000000", -- ldi a,$0000
        x"0E000001", --     addi a,1
        x"23000002", --     subr WAIT
        x"0100FFFE", --     rjmp COUNTER
        x"08300FFF", --     ldi d,$0FFF
        x"10300001", --     subi d,1
        x"0300FFFF", --     bne WAIT_LOOP
        x"24000000", --     ret
        x"08001337", --     ldi a,$1337
        x"00000000", --     nop
        x"0100FFFF", --     rjmp -1

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
