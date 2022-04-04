library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity PROG_MEM is
	Port( 	addr : in unsigned(15 downto 0);
		data_out : out unsigned(31 downto 0);
		clk, we : in std_logic;
		wr_addr : in unsigned(15 downto 0);
		wr_data : in unsigned(31 downto 0));
end PROG_MEM;

architecture func of PROG_MEM is

	type PM_t is array(0 to 4095) of unsigned(31 downto 0);
	constant PM_c : PM_t := (
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
