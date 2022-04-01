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
    signal UART_in : std_logic := '0';

    signal rx : std_logic;

    constant FPGA_clk_period : time := 10 ns;
begin
    

    -- Component Instantiation
    U0: lab port map(
        clk => clk,
        rst => rst,
        UART_in => rx);

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
            ("00001010", -- ir1 opcode
             "00000001", -- ir1 registers
             "00000000", -- ir1 constant byte1
             "00000000", -- ir1 constant byte2
             "00001001", -- ir2 opcode
             "00100000", -- ir2 registers
             "11111111", -- ir2 constant byte1
             "11111111"  -- ir2 constant byte2
            );
    begin
        rst <= '1';
        wait for FPGA_clk_period * 10; -- wait a while with reset high
        wait until rising_edge(clk); -- needed? wait until syncron release

        rst <= '0';

        for i in patterns'range loop

            rx <= '0'; -- start bit
            wait for FPGA_clk_period;
            
            for j in 0 to 7 loop
                rx <= patterns(i)(j)
                wait for 8.68 us;
            end loop; -- j

            rx <= '0'; -- stop bit
            wait for FPGA_clk_period;

        end loop; -- i
        wait; -- wait forever, will finish simulation
    end process;
  
    rst <= '1', '0' after 25 ns;
END;

