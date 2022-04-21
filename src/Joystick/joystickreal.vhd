library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


--  ===================================================================================
--  								Define Module, Inputs and Outputs
--  ===================================================================================

entity joystickreal is
    Port (  CLK : in  STD_LOGIC;								-- 100Mhz onboard clock
            RST : in  STD_LOGIC;           								-- Button DNN
            MISO : in std_logic;
            SS : inout  STD_LOGIC;								-- Slave Select, Pin 1, Port JA
            SCLK: out  STD_LOGIC;            							-- Serial Clock, Pin 4, Port JA
            MOSI : out  STD_LOGIC							-- Master Out Slave In, Pin 2, Port JA
            );
    end joystickreal;

architecture Behavioural of joystickreal is
    signal bits_sent : unsigned(6 downto 0) := (others => '0');
    signal sclk_counter : unsigned (15 downto 0) := (others => '0');
    signal sclk_inner : std_logic;
    constant sclk_speed : unsigned (15 downto 0) := x"07CF"; -- 1999



    begin

SCLK <= sclk_inner;
-- 50kbps clock for joystick, if more than 5 bytes are sent without 
-- switching ss to 1 the joystick will stop reciving data
process(clk) begin 
    if rising_edge(clk) then
        if (ss = '1' or RST = '1') then -- ss = 1 means joystick is disabled
            sclk_counter <= x"0000";
            bits_sent <= "0000000";
            sclk_inner <= '0';
        elsif (ss = '0' and bits_sent /= 40) then -- if joystick is enabled
            if (sclk_counter = sclk_speed) then
                sclk_counter <= x"0000";
                if (sclk_inner = '1') then
                    bits_sent <= bits_sent + 1;
                    sclk_inner <= '0';
                else 
                    sclk_inner <= '1';
                end if;
            else
                sclk_counter <= sclk_counter + 1;
            end if;
        end if;
    end if;
end process;
end architecture;





