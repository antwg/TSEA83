library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity realcpu_tb is
end realcpu_tb;

architecture sim of realcpu_tb is

    component pipeCPU is
        port( clk, rst : in std_logic;
              UART_in : in std_logic;
              UART_out : out std_logic);
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
          --  x"0800000A", -- ldi a, 10
          --  x"08100004", -- ldi b, 4
          --  x"0F010000", -- sub a, b ; a = 6
          --  x"0E000002", -- addi a, 2 ; a = 8
          --  x"10100002", -- subi b, 2 ; b = 2
          --  x"0D010000", -- add a, b ; a = 10
          --  x"20000000", -- lsrs a ; a = 5
          --  x"1C000003", -- muli, a, 3 ; a = 15
          --  x"1F100000", -- lsls b ; b = 4
          --  x"1B010000", -- mul a, b ; a = 60
          --  x"0B100000", -- st b, a ; store a = 60 on addr b = 4
          --  x"08000000", -- ldi a, 0 ; a = 0
          --  x"09010000", -- ld a, b ; a = 60
          --  x"1E00FFFF", -- mulsi a, -1 ; a = -60 
          --  x"14000007", -- andi a, 7  ; a = 4
          --  x"08100008", -- ldi b, 8
          --  x"15010000", -- or a, b ; a = 12  
          --  x"16000000", -- ori a, 16; a = 28
          --  x"13000000", -- and a, b; a = 8
          --  x"1D000000", -- muls a, a ; a = 64
          --  x"00000000", -- nop
          --  x"0100FFFF", -- rjmp -1

            (
             x"08", x"00", x"0a", x"00",
             x"08", x"10", x"04", x"00",
             x"0f", x"01", x"00", x"00",
             x"0e", x"00", x"02", x"00",
             x"10", x"10", x"02", x"00",
             x"0d", x"01", x"00", x"00",
             x"20", x"00", x"00", x"00",
             x"1c", x"00", x"03", x"00",
             x"1f", x"10", x"00", x"00",
             x"1b", x"01", x"00", x"00",
             x"0b", x"10", x"00", x"00",
             x"08", x"00", x"00", x"00",
             x"09", x"01", x"00", x"00",
             x"1e", x"00", x"ff", x"ff",
             x"14", x"00", x"07", x"00",
             x"08", x"10", x"08", x"00",
             x"15", x"01", x"00", x"00",
             x"16", x"00", x"00", x"00",
             x"13", x"00", x"00", x"00",
             x"1d", x"00", x"00", x"00",
             x"00", x"00", x"00", x"00",
             x"01", x"00", x"ff", x"ff",
             x"ff");
    begin
        wait for 100000 ns; -- be idle for a bit at the start

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

	rst <= '1', '0' after 10 ns;

end architecture;
