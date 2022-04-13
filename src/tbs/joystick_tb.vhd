library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity joystick_tb is
end joystick_tb;

architecture behavioural of joystick_tb is 

component joystick is 
    Port (
        clk : in std_logic;
        rst : in std_logic;
        sw : in STD_LOGIC_VECTOR(2 downto 0);
        joy_out : out unsigned(1 downto 0)
    );
    end component;


    signal clk : std_logic := '0';
    signal rst : std_logic := '0';
    signal sw : std_logic_vector (2 downto 0):= (others => '0');
    signal joy_out : unsigned (1 downto 0);
    constant FPGA_clk_period : time := 10 ns;
    
begin

    clk_process : process
    begin 
        clk <= '0';
        wait for FPGA_clk_period/2;
        clk <= '1';
        wait for FPGA_clk_period/2;
    end process; 


J_CMP : joystick port map (
    clk => clk,
    rst => rst,
    sw => sw,
    joy_out => joy_out
);



end;