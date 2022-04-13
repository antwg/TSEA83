library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity realcpu_tb is
end realcpu_tb;

architecture sim of realcpu_tb is

component pipeCPU is
	port(
		clk : in std_logic;
		rst : in std_logic;
        UART_in : in std_logic;
        UART_out : in std_logic);
end component;

	signal clk : std_logic;
	signal rst : std_logic;
	signal UART_in : std_logic := '1'; -- needed else fails
	signal UART_out : std_logic := '0';

begin

	U0 : pipeCPU port map(
		clk => clk,
		rst => rst,
		UART_in => UART_in,
        UART_out => UART_out);

    UART_stimuli : process
        type pattern_array is array(natural range <>) of unsigned (7 downto 0);
        constant patterns : pattern_array :=
            -- x"08000004", -- ldi a,4
            -- x"0E000002", -- addi a,2
            -- x"00000000", -- NOP
            -- x"0100FFFF", -- RJMP -1

            -- 0xFF EOF
            (x"08", -- ir1 opcode
             x"00", -- ir1 registers
             x"04", -- ir1 constant byte1
             x"00", -- ir1 constant byte2
             x"0E", -- ir2 opcode
             x"00", -- ir2 registers
             x"02", -- ir2 constant byte1
             x"00", -- ir2 constant byte2
             x"00", -- ir3 opcode
             x"00", -- ir3 registers
             x"00", -- ir3 constant byte1
             x"00", -- ir3 constant byte2
             x"01", -- ir4 opcode
             x"00", -- ir4 registers
             x"FF", -- ir4 constant byte1
             x"FF", -- ir4 constant byte2
             x"FF"); -- EOF indicator
    begin
        wait for 1000 ns; -- be idle for a bit at the start

        for i in patterns'range loop

            UART_in <= '0'; -- start bit
            wait for 8.68 us;
                
            for j in 0 to 7 loop
                UART_in <= patterns(i)(j);
                wait for 8.68 us;
            end loop; -- j

            UART_in <= '1'; -- stop bit
            wait for 8.68 us;

        end loop; -- i
        wait; -- wait forever, will finish simulation
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
