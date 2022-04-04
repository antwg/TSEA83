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

    -- Component Instantiation
    U0: ALU port map(
        clk => clk,
        result => result,
        MUX1 => MUX1,
        MUX2 => MUX2,
        op_code => op_code);

    clk_process : process
    begin
        clk <= '0';
        wait for FPGA_clk_period/2;
        clk <= '1';
        wait for FPGA_clk_period/2;
    end process;
END;
