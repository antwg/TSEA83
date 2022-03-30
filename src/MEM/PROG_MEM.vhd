library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity PROG_MEM is
	port(
		addr : in unsigned(15 downto 0);
		data_out : out unsigned(25 downto 0)
		);
end PROG_MEM;

architecture func of PROG_MEM is

	type PM_t is array(0 to 4095) of unsigned(25 downto 0);
	constant PM_c : PM_t := (
		"00100111111111111111111110",	-- dummy
		"00110100100000000000000000",	-- dummy
		"00000111111111111111111110",	-- dummy
		"10000000000000000000000000",	-- dummy
		"10000000000000000000000000",	-- dummy
		"10000000000000000000000000",	-- dummy

		others => (others => '0')
	);

	signal PM : PM_t := PM_c;

begin
	data_out <= PM(to_integer(addr));
end func;
