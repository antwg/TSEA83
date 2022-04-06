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
        UART_in : in std_logic);
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

		clk <= '0';
		wait for 5 ns;
		clk <= '1';
		wait for 5 ns;

	end process;

	rst <= '1', '0' after 7 ns;

end architecture;
