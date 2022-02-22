library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity PM_comp is
	port(
		addr : in unsigned(8 downto 0);
		data_out : out unsigned(31 downto 0)
		);
end PM_comp;

architecture func of PM_comp is

	type PM_t is array(0 to 511) of unsigned(31 downto 0);
	constant PM_c : PM_t := (
		X"04000000",	-- dummy
		X"08000000",	-- dummy
		X"540007FE",	-- J 0
		X"0C000000",	-- dummy
		X"10000000",	-- dummy
		
		others => (others => '0')
	);
	
	signal PM : PM_t := PM_c;
	
	begin
		
		data_out <= PM(to_integer(addr));
	
	end architecture;