library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity REG_FILE is
	port(
		clk : std_logic;
        led_addr : in unsigned(3 downto 0);
        led_out : out unsigned(15 downto 0);
		rd_in : in unsigned(3 downto 0);
		rd_out : out unsigned(15 downto 0);
		ra_in : in unsigned(3 downto 0);
		ra_out : out unsigned(15 downto 0);
		we : in std_logic;
		data_in : in unsigned(15 downto 0);
		jstk_data : in unsigned(22 downto 0);
		jstk_en : out std_logic;
		jstk_done : in std_logic

		);

end REG_FILE;

architecture func of REG_FILE is

	alias x is jstk_data(9 downto 0) ; -- joystick x positon 
	alias y is jstk_data(19 downto 10); -- joystick y position 
	alias btns is jstk_data(22 downto 20); -- joystick btns
 

	type RF_t is array(0 to 15) of unsigned(15 downto 0);
	constant RF_c : RF_t := (
		others => (others => '0')
	);

	signal RF : RF_t := RF_c;

begin
      process(clk)
        begin
          if rising_edge(clk) then
            if we = '1' then
                RF(to_integer(rd_in)) <= data_in;
            end if;
         end if;
        end process;

	rd_out <= RF(to_integer(rd_in));
	ra_out <= RF(to_integer(ra_in));
    led_out <= RF(to_integer(led_addr));
end architecture;
