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
		JA : inout unsigned(15 downto 0));
end REG_FILE;

architecture func of REG_FILE is

	alias SS is JA(0) ; -- pin 1
	alias MOSI is JA(1); -- pin 2
	alias MISO is JA(2); -- pin 3
	alias SCLK is JA(3); -- pin 4

	type RF_t is array(0 to 15) of unsigned(15 downto 0);
	constant RF_c : RF_t := (
        x"FEED",
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

			-- Joystick IO register
			RF(15)(0) <= JA(0); -- register bit 0 to ss
			RF(15)(1) <= JA(1);	-- regsiter bit 1 to MOSI
			JA(2) <= RF(15)(2);	-- MISO to register bit 2 
			JA(3) <= RF(15)(3);	-- SCLK to register bit 3
			JA(4) <= RF(15)(4);
			JA(5) <= RF(15)(5);
			JA(6) <= RF(15)(6);
			JA(7) <= RF(15)(7);
		
         end if;
        end process;

	rd_out <= RF(to_integer(rd_in));
	ra_out <= RF(to_integer(ra_in));
    led_out <= RF(to_integer(led_addr));
end architecture;
