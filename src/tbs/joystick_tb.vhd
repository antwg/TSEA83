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
	alias SS is JA(0) ; -- pin 1
	alias MOSI is JA(1); -- pin 2
	alias MISO is JA(2); -- pin 3
	alias SCLK is JA(3); -- pin 4
    
    signal clk: STD_LOGIC;								-- 100Mhz onboard clock
    signal RST : STD_LOGIC;           								-- Button DNN
    constant FPGA_clk_period : time := 10 ns;
    signal enable : std_logic;
    signal timer : unsigned(4 downto 0);
begin
J_CMP : joystickreal port map (
    clk => clk,
    enable => enable,
    RST => RST,
    JA => JA
);

    rst <= '1', '0' after 7 ns;
    enable <= '0', '1' after 100 us; 
    -- send 10 from the joystick to
    -- the fpga
    with timer select 
        MISO <=  '1' when "00101",
                 '1' when "00111",
                 '0' when others;


    MOSI_timer : process begin
        if rising_edge(SCLK) then
            if (timer < 40)  then
            timer <= timer +1;
            elsif (timer = 40) then
                timer <= "00000";
            end if;
        end if;
    end process;

    clk_process : process
    begin 
        clk <= '0';
        wait for FPGA_clk_period/2;
        clk<= '1';
        wait for FPGA_clk_period/2;
    end process; 



end;