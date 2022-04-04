library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity alu_tb is
end alu_tb;

architecture behavior of alu_tb is

  -- Component Declaration
    component ALU is
        port(
            clk : in std_logic;
            result : out unsigned(15 downto 0);
            MUX1 : in unsigned(15 downto 0);
            MUX2 : in unsigned(15 downto 0);
            op_code : in unsigned(7 downto 0));
    end component;

    signal clk : std_logic := '0';
    signal result : unsigned(15 downto 0);
    signal MUX1 : unsigned(15 downto 0) := "0000000000000001";
    signal MUX2 : unsigned(15 downto 0) := "0000000000000001";
    signal op_code : unsigned(7 downto 0) := "00001111";

    constant FPGA_clk_period : time := 10 ns;
begin





    clk_process : process
    begin
        clk <= '0';
        wait for FPGA_clk_period/2;
        clk <= '1';
        wait for FPGA_clk_period/2;
    end process;

    UART_stimuli : process
        type pattern_array is array(natural range <>) of unsigned (39 downto 0);
        constant patterns : pattern_array := 
            (x"0D0001FFFF", -- add 1+FFFF, C
            x"0D00017FFF", -- add 1+7FFF, V
             x"0E00010003", -- addi 1+3 
             x"1D00030008", -- mul 3*8 
             x"1A00040004", -- sub 8-4 
             x"0F0008000A", -- subi 8 - 10, V, N
             x"1F00020000", -- logic shift left 010 -> 100 
             x"2000030000",  -- logic shift right 011 -> 001, carry set 
             x"20FFFF0000",  -- logic shift right  FFFF -> 0..., carry set 
             x"1FFFFF0000",  -- logic shift left FFFF -> ...0, carry set 
             x"14FFFF0000",  --andi, 0000 and FFFF -> 0000 
             x"13FFFF0F0F",  --and, 0F0F and FFFF -> 0F0F 
             x"150F0F0F0F",  --or, F0F0 or F0F0 -> F0F0 
             x"16F0F00F0F"  --ori, 0F0F or FFFF -> FFFF
            );
    begin
        for i in patterns'range loop
            
           op_code <= patterns(i)(39 downto 32);
           MUX1 <= patterns(i)(31 downto 16);
           MUX2 <= patterns(i)(15 downto 0);
            
           
           
           wait for 10 us;
           
        end loop; -- i
        wait; -- wait forever, will finish simulation
    end process;




    -- Component Instantiation
    U0: ALU port map(
        clk => clk,
        result => result,
        MUX1 => MUX1,
        MUX2 => MUX2,
        op_code => op_code);

    END;
