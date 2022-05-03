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
            enable : in std_logic;
            done : out std_logic:= '0';
            data_out: out unsigned(22 downto 0) := (others => '0');
            JA : inout unsigned(3 downto 0) 
    
           );
    end joystickreal;

architecture Behavioural of joystickreal is
    signal bits_sent : unsigned(6 downto 0) := (others => '0');
    signal sclk_counter : unsigned (15 downto 0) := (others => '0');
    signal x: unsigned(9 downto 0) := (others => '0');   
    signal y: unsigned(9 downto 0):= (others => '0');
    signal btns: unsigned(2 downto 0):= (others => '0');  
    signal SCLK_old : std_logic := '0'; 
    signal fall_edge_SCLK_enp : std_logic := '0';
    signal MOSI_out : unsigned(7 downto 0):= "10000000";
    signal rise_edge_SCLK_enp : std_logic := '0';
    constant sclk_speed : unsigned (15 downto 0) := x"07CF"; -- 1999
    signal leds : unsigned(1 downto 0):= "11";
	alias SS is JA(0) ; -- pin 1
	alias MOSI is JA(1); -- pin 2
	alias MISO is JA(2); -- pin 3
	alias SCLK is JA(3); -- pin 41
    -- Pin 3 master in slave out
    -- Slave Select, Pin 1, Port JA
    -- Serial Clock, Pin 4, Port JA
    -- Master Out Slave In, Pin 2, Port JA;

    begin

fall_edge_SCLK_enp <= (not SCLK) and not SCLK_old;
rise_edge_SCLK_enp <= (SCLK) and SCLK_old;

SS <= not enable; -- ss is the opposite of what makes sense, 0 is enable 1 is disable
data_out <= x&y&btns;

MOSI <= MOSI_out(7);

process(clk) begin
    --send data to joystick
    if rising_edge(clk) then
        SCLK_old <= not SCLK;
        
        if (bits_sent = 0) then
            MOSI_out <= "100000"&leds;
        elsif (rise_edge_SCLK_enp = '1' and bits_sent /= 1) then
            MOSI_out <= MOSI_out(6 downto 0)&'0';
        end if;
       

        if (fall_edge_SCLK_enp = '1') then
            --x data from joystick
            if (bits_sent < 9) then
                x <= x(8 downto 0)&MISO; -- shift in miso
            elsif (bits_sent = 15) then
                x(9) <= MISO;
            elsif (bits_sent = 16) then
                x(8) <= MISO;
        
            --y data from joystick
            elsif (( bits_sent > 16 ) and ( bits_sent < 25 )) then
                y <= y(8 downto 0)&MISO; -- shift in miso
            elsif (bits_sent = 31) then
                y(9) <= MISO;
            elsif (bits_sent = 32) then
                y(8) <= MISO;
                -- get buttons data
            elsif (bits_sent = 38) then
                btns(2) <= MISO;
            elsif (bits_sent = 39) then
                btns(1) <= MISO;
            elsif (bits_sent = 40) then
                btns(0) <= MISO;
                done <= '1';
                -- this should cause leds on joystick to blink
                leds <= leds - 1;
                end if;
        elsif(SS = '1' or rst = '1') then
            x <= "0000000000";
            y <= "0000000000";
            btns <= "000";
        end if;
    
        if (bits_sent /= 40) then
            done <= '0';
        end if;

    end if;
end process;


-- 50kbps clock for joystick, if more than 5 bytes are sent without
-- switching ss to 1 the joystick will stop reciving datA
    
process(clk) begin 
    if rising_edge(clk) then
        if (SS = '1' or RST = '1') then -- ss = 1 means joystick is disabled
            sclk_counter <= x"0000";
            bits_sent <= "0000000";
            SCLK <= '0';

        elsif (SS = '0') then -- if joystick is enabled
            if (sclk_counter = sclk_speed) then
                sclk_counter <= x"0000";
                if (SCLK = '1') then
                    SCLK <= '0';
                else 
                    if(bits_sent = 40) then -- set the last falling edge
                        SCLK <= '0';
                    else 
                        bits_sent <= bits_sent + 1;
                        SCLK <= '1';
                    end if;
                end if;
            else
                sclk_counter <= sclk_counter + 1;          
            end if;
        end if;
    end if;
end process;
end architecture;





