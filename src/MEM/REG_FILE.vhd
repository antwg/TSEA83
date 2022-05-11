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
		jstk_en : out std_logic := '0';
		jstk_done : in std_logic

		);

end REG_FILE;

architecture func of REG_FILE is

	alias x is jstk_data(9 downto 0) ; -- joystick x positon 
	alias y is jstk_data(19 downto 10); -- joystick y position 
	alias btns is jstk_data(22 downto 20); -- joystick btns
 

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

			--enable joystick bit
			jstk_en <= RF(15)(15);

			if we = '1' then
                RF(to_integer(rd_in)) <= data_in;
				if (jstk_done = '1') then
					-- y data
					RF(14)(0) <= jstk_data(3);
					RF(14)(1) <= jstk_data(4);
					RF(14)(2) <= jstk_data(5);
					RF(14)(3) <= jstk_data(6);
					RF(14)(4) <= jstk_data(7);
					RF(14)(5) <= jstk_data(8);
					RF(14)(6) <= jstk_data(9);
					RF(14)(7) <= jstk_data(10);
					RF(14)(8) <= jstk_data(11);
					RF(14)(9) <= jstk_data(12);
					--buttons
					RF(15)(10) <= jstk_data(0);
					RF(15)(11) <= jstk_data(1);
					RF(15)(12) <= jstk_data(2);
					--x data	
					RF(15)(0) <= jstk_data(13);
					RF(15)(1) <= jstk_data(14);
					RF(15)(2) <= jstk_data(15);
					RF(15)(3) <= jstk_data(16);
					RF(15)(4) <= jstk_data(17);
					RF(15)(5) <= jstk_data(18);
					RF(15)(6) <= jstk_data(19);
					RF(15)(7) <= jstk_data(20);
					RF(15)(8) <= jstk_data(21);
					RF(15)(9) <= jstk_data(22);
			elsif (jstk_done = '1') then
				-- y data
				RF(14)(0) <= jstk_data(3);
				RF(14)(1) <= jstk_data(4);
				RF(14)(2) <= jstk_data(5);
				RF(14)(3) <= jstk_data(6);
				RF(14)(4) <= jstk_data(7);
				RF(14)(5) <= jstk_data(8);
				RF(14)(6) <= jstk_data(9);
				RF(14)(7) <= jstk_data(10);
				RF(14)(8) <= jstk_data(11);
				RF(14)(9) <= jstk_data(12);
				--buttons
				RF(15)(10) <= jstk_data(0);
				RF(15)(11) <= jstk_data(1);
				RF(15)(12) <= jstk_data(2);
				--x data	
				RF(15)(0) <= jstk_data(13);
				RF(15)(1) <= jstk_data(14);
				RF(15)(2) <= jstk_data(15);
				RF(15)(3) <= jstk_data(16);
				RF(15)(4) <= jstk_data(17);
				RF(15)(5) <= jstk_data(18);
				RF(15)(6) <= jstk_data(19);
				RF(15)(7) <= jstk_data(20);
				RF(15)(8) <= jstk_data(21);
				RF(15)(9) <= jstk_data(22);
				end if;
			end if;
         end if;
        end process;

	rd_out <= RF(to_integer(rd_in));
	ra_out <= RF(to_integer(ra_in));
    led_out <= RF(to_integer(led_addr));
end architecture;
