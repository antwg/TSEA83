library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity REG_FILE is
	port(
		rd : in unsigned(3 downto 0);
		rd_out : out unsigned(15 downto 0);
		ra : in unsigned(3 downto 0);
		ra_out : out unsigned(15 downto 0);
		we : in unsigned(0);
		data_in : in unsigned(15 downto 0)
		);
end REG_FILE;

architecture func of REG_FILE is

	type RF_t is array(0 to 15) of unsigned(15 downto 0);
	constant RF_c : RF_t := (
		"1000000000000000",	-- dummy

		others => (others => '0')
	);

	signal RF : RF_t := RF_c;

begin
	rd_out <= RF(to_integer(rd));
	ra_out <= RF(to_integer(ra));
end func;
