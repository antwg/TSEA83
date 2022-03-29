library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity DATA_MEM is
	port(
		addr : in unsigned(15 downto 0);
		data_out : out unsigned(15 downto 0)
		);
end DATA_MEM;

architecture func of DATA_MEM is

	type DM_t is array(0 to 4095) of unsigned(25 downto 0);
	constant DM_c : DM_t := (
		others => (others => '0')
	);

	signal DM : DM_t := DM_c;

begin
	data_out <= DM(to_integer(addr));
end func;
