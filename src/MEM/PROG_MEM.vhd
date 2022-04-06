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
		x"08000004", -- LDI a,4
		x"08100045", -- LDI b,45
		x"10000002", -- SUBI a,2
		x"0B100002", -- ST b,a (MEM(b) <= a)
		x"00000000", -- NOP
		x"0100FFFF", -- RJMP -1
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

	data_out <= PM(to_integer(addr));
end func;
