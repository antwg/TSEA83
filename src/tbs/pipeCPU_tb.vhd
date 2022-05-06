library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity pipeCPU_tb is
end pipeCPU_tb;

architecture sim of pipeCPU_tb is

component pipeCPU is
	port(
		clk : in std_logic;
		rst : in std_logic;
        UART_in : in std_logic;
	
		MISO : in std_logic;
		SS : out std_logic;
		SCLK : out std_logic;
		MOSI : out std_logic
		);
end component;

	signal clk : std_logic;
	signal rst : std_logic;
	signal rx : std_logic;
	signal timer : unsigned(5 downto 0) := "000000";
	signal SCLK_en : std_logic;
	signal MISO :std_logic;
	signal	SS :  std_logic;
	signal	SCLK :  std_logic;
	signal	MOSI :  std_logic;
	
begin

	U0 : pipeCPU port map(
		clk => clk,
		rst => rst,
		UART_in => rx,	
		MISO => MISO,
		SCLK => SCLK,
		MOSI => MOSI,
		SS => SS
		);

--    with timer select 
--        MISO <=  --'1' when "000101",
--                -- '1' when "000111",
--				-- '1' when  "001010", 
--				-- '1' when  "001011", 
--				-- '1' when  "001100", 
--				-- '1' when  "001110", 
-- 
--				 '1' when others;
--
process(clk) begin
--send data to joystick
if rising_edge(clk) then
	if (timer < 9) then
			MISO <= '1';
		elsif (timer = 15) then
			MISO <= '1';
		elsif (timer = 16) then
			MISO <= '1';
	
		--y data from joystick
		elsif (( timer > 16 ) and ( timer < 25 )) then
			MISO <= '1';
		elsif (timer = 31) then
			MISO <= '1';
		elsif (timer = 32) then
			MISO <= '1';
			-- get buttons data
		elsif (timer = 38) then
			MISO <= '1';
		elsif (timer = 39) then
			MISO <= '1';
		elsif (timer = 40) then
			MISO <= '1';
		else 
			MISO <= '0';
		end if;
	end if;
end process;




    MOSI_timer : process(clk) begin
     
		if rising_edge(clk) then
			if (SCLK = '0') then
				SCLK_en <= '0';
			elsif (SCLK = '1' and SCLK_en = '0') then
				SCLK_en <= '1';
        	    if (timer < 40)  then
            	timer <= timer +1;
            	elsif (timer = 40) then
                	timer <= "000000";
				end if;
			end if;
        end if;
    end process;

	process
	begin

		clk <= '0';
		wait for 5 ns;
		clk <= '1';
		wait for 5 ns;

	end process;

	rst <= '1', '0' after 7 ns;

end architecture;
