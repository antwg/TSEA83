library IEEE;
use IEEE.std_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.all;

entity PROG_LOADER is
	Port ( clk, rst, rx : in std_logic;
	       we : out std_logic;
	       addr : out unsigned(15 downto 0);
	       data_out : out unsigned(25 downto 0));
end PROG_LOADER;

architecture func of PROG_LOADER is
	signal sreg : unsigned(27 downto 0) := B"0_00000000000000000000000000_0";
	signal rx1, rx2 : std_logic; -- synkvippor
	signal sp : std_logic;

	-- addr counter
	signal addr_cnt_en : std_logic := '0';
	signal addr_cnt_rst : std_logic := '0';
	signal addr_cnt_out : unsigned(15 downto 0);

	-- 868 counter
   	signal st_868_cnt_en  : std_logic := '0'; 	-- enable 868 counter
    	signal st_868_cnt_rst : std_logic := '0'; 	-- reset counter
    	signal st_868_cnt_out : unsigned(10 downto 0) := B"00000000000"; -- counter out

	-- 26 counter
   	signal st_26_cnt_en  : std_logic := '0'; 	-- enable 868 counter
    	signal st_25_cnt_rst : std_logic := '0'; 	-- reset counter
    	signal st_26_cnt_out : unsigned(10 downto 0) := B"00000000000"; -- counter out

begin

	-- sync rx
	process(clk) begin
		if rising_edge(clk) then
			rx1 <= rx;
			rx2 <= rx1;
		end if;
	end process;

	-- control unit
	process(clk) begin
	    if rising_edge(clk) then
		if (rx1 = '0' and rx2 = '1' and st_868_cnt_en = '0') then -- start bit
			st_868_cnt_en <= '1';
		elsif ((lp = '1') and (rx2 = '1')) then -- stop bit
			st_868_cnt_en <= '0';
		end if;
	    end if;
	end process;

	-- 868, 26 and addr counters
	process(clk) begin
	    if rising_edge(clk) then
		    if (st_868_cnt_rst='1') then
			st_868_cnt_out <= "00000000000";
		    elsif (st_868_cnt_en='1') then
			st_868_cnt_out <= st_868_cnt_out + 1;
		    end if;

		    if (st_26_cnt_rst='1') then
			st_26_cnt_out <= "00000000000";
		    elsif (st_26_cnt_en='1') then
			st_26_cnt_out <= st_26_cnt_out + 1;
		    end if;

		    if (addr_cnt_rst='1') then
			addr_cnt_out <= "00000000000";
		    elsif (addr_cnt_en='1') then
			addr_cnt_out <= addr_cnt_out + 1;
		    end if;
	    end if;
	end process;

	-- write to memory when we reach 26 things in shift register
	we <= '1' when st_26_cnt_out=26 else '0';

	-- shift halway through a char
	sp <= '1' when st_868_cnt_out=434 else '0';

	-- count up until 868 counts, every such count increases the 26 counter (e.g. char hase come in)
	st_868_cnt_rst <= '1' when st_868_cnt_out=868 else '0';
	st_26_cnt_en <= '1' when st_868_cnt_rst='1' else '0';
	st_26_cnt_rst <= '1' when st_26_cnt_out=26 else '0';

	-- not sure how this will work
	addr_cnt_enable <= '1' when st_26_cnt_rst='1' else '0';

	-- addr counter
	addr <= addr_cnt_out;
	
	-- 26 bit shift register
	process(clk) begin
	    if rising_edge(clk) then
		if sp='1' then
			sreg <= sreg sll 1;
			sreg(0) <= rx2;
		else
			sreg <= sreg;
		end if;
	    end if;
	end process;
end func;
