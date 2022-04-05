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
		seg : out unsigned(7 downto 0);
		an : out unsigned(3 downto 0)
		);
end component;

	signal clk : std_logic;
	signal rst : std_logic;
	signal rx : std_logic;

begin

	U0 : pipeCPU port map(
		clk => clk,
		rst => rst,
		UART_in => rx);

	process
	begin

		for i in 0 to 1000 loop
			clk <= '0';
			wait for 5 ns;
			clk <= '1';
			wait for 5 ns;
		end loop;

		wait; -- wait forever, will finish simulation
	end process;

	rst <= '1', '0' after 7 ns;

end architecture;
