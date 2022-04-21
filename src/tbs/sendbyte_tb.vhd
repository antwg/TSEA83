library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity sendbyte_tb is
end sendbyte_tb;

architecture sim of sendbyte_tb is
    component pipeCPU is
        port( clk, rst : in std_logic;
              UART_in : in std_logic;
              UART_out : out std_logic);
    end component;

	signal clk : std_logic;
	signal rst : std_logic;
	signal rx : std_logic := '1'; -- needed else fails
	signal tx : std_logic := '0';
begin
	U0 : pipeCPU port map(
		clk => clk,
		rst => rst,
		UART_in => rx,
        UART_out => tx);

	process
	begin
		clk <= '0';
		wait for 5 ns;
		clk <= '1';
		wait for 5 ns;
	end process;

	rst <= '1', '0' after 7 ns;
end architecture;
