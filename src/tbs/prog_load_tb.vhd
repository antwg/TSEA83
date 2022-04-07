library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity prog_load_tb is
end prog_load_tb;

architecture behavior of prog_load_tb is 

  -- Component Declaration
    component pipeCPU is
        port(
            clk, rst : in std_logic;
            UART_in : in std_logic);
    end component;

    signal clk : std_logic := '0';
    signal rst : std_logic := '0';
    signal UART_in : std_logic := '1';

    constant FPGA_clk_period : time := 10 ns;
begin
    -- Component Instantiation
    U0: pipeCPU port map(
        clk => clk,
        rst => rst,
        UART_in => UART_in);

    clk_process : process
    begin
        clk <= '0';
        wait for FPGA_clk_period/2;
        clk <= '1';
        wait for FPGA_clk_period/2;
    end process;

    UART_stimuli : process
        type pattern_array is array(natural range <>) of unsigned (7 downto 0);
        constant patterns : pattern_array :=
            (x"08", -- ir1 opcode
             x"00", -- ir1 registers
             x"04", -- ir1 constant byte1
             x"00", -- ir1 constant byte2
             x"08", -- ir2 opcode
             x"10", -- ir2 registers
             x"45", -- ir2 constant byte1
             x"00", -- ir2 constant byte2
             x"10", -- ir3 opcode
             x"00", -- ir3 registers
             x"02", -- ir3 constant byte1
             x"00", -- ir3 constant byte2
             x"0b", -- ir4 opcode
             x"10", -- ir4 registers
             x"00", -- ir4 constant byte1
             x"00", -- ir4 constant byte2
             x"00", -- ir5 opcode
             x"00", -- ir5 registers
             x"00", -- ir5 constant byte1
             x"00", -- ir5 constant byte2
             x"01", -- ir6 opcode
             x"00", -- ir6 registers
             x"FF", -- ir6 constant byte1
             x"FF", -- ir6 constant byte2
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
  
    rst <= '1', '0' after 50 ns;
END;

