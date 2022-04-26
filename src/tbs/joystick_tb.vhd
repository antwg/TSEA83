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
            enable: in std_logic;
            done : out std_logic;
            data_out: out unsigned(22 downto 0);
            JA : inout unsigned(7 downto 0)
            );
    end component;

    signal JA : unsigned(7 downto 0):= (others => '0');
    signal clk: STD_LOGIC;								-- 100Mhz onboard clock
    signal RST : STD_LOGIC;           								-- Button DNN
    signal MISO :std_logic;
    constant FPGA_clk_period : time := 10 ns;
    signal enable : std_logic;
begin
J_CMP : joystickreal port map (
    clk => clk,
    enable => enable,
    RST => RST,
    JA => JA
);

    rst <= '1', '0' after 7 ns;
    enable <= '0', '1' after 100 us; 
    
    clk_process : process
    begin 
        clk <= '0';
        wait for FPGA_clk_period/2;
        clk<= '1';
        wait for FPGA_clk_period/2;
    end process; 



end;