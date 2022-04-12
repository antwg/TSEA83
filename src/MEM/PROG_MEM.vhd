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

	type PM_t is array(0 to 100) of unsigned(31 downto 0);
	constant PM_c : PM_t := (
        x"08000008", -- ldi a, 8
        x"0810000A", -- ldi b, 10
        x"0B100000", -- st b, a
        x"09210000", -- ld c, b
        x"20200000", -- lsrs c
        x"0C020000", -- copy a, c
        x"0E000001", -- addi a, 1
        x"00000000", -- nop
        x"0100FFFF", -- rjmp -1
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
