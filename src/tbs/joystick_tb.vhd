library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity joystick_tb is
end joystick_tb;

architecture behavioural of joystick_tb is 

component joystickreal is 
    Port (clk: in  STD_LOGIC;								-- 100Mhz onboard clock
            RST : in  STD_LOGIC;           								-- Button DNN
            MISO: in std_logic;
            SS: inout  STD_LOGIC;								-- Slave Select, Pin 1, Port JA
            SCLK: out  STD_LOGIC;            							-- Serial Clock, Pin 4, Port JA
            MOSI: out  STD_LOGIC							-- Master Out Slave In, Pin 2, Port JA
            );
    end component;


    signal clk: STD_LOGIC;								-- 100Mhz onboard clock
    signal RST : STD_LOGIC;           								-- Button DNN
    signal MISO :std_logic;
    constant FPGA_clk_period : time := 10 ns;

begin
J_CMP : joystickreal port map (
    clk => clk,
    RST => RST,
    MISO => MISO
);

    rst <= '1', '0' after 7 ns;
    --SS <= '0', '1' after 20 us;



    clk_process : process
    begin 
        clk <= '0';
        wait for FPGA_clk_period/2;
        clk<= '1';
        wait for FPGA_clk_period/2;
    end process; 



end;