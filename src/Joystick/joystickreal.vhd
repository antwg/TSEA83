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
            SS : out  std_logic:= '1';
            MOSI : out  std_logic:= '0';
            MISO : in  std_logic;
            SCLK : out  std_logic := '0'
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
    signal SS_in,MOSI_in,SCLK_in : std_logic;

    -- Pin 3 master in slave out
    -- Slave Select, Pin 1, Port JA
    -- Serial Clock, Pin 4, Port JA
    -- Master Out Slave In, Pin 2, Port JA;

    begin


SS <= SS_in;
MOSI <= MOSI_in;
SCLK <= SCLK_in;

fall_edge_SCLK_enp <= (not SCLK_in) and not SCLK_old;
rise_edge_SCLK_enp <= (SCLK_in) and SCLK_old;

SS_in <= not enable; -- ss is the opposite of what makes sense, 0 is enable 1 is disable
data_out <= x&y&btns;

MOSI_in <= MOSI_out(7);

process(clk) begin
    --send data to joystick
    if rising_edge(clk) then
        SCLK_old <= not SCLK_in;
        
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
        elsif(SS_in = '1' or rst = '1') then
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
        if (SS_in = '1' or RST = '1') then -- ss = 1 means joystick is disabled
            sclk_counter <= x"0000";
            bits_sent <= "0000000";
            SCLK_in <= '0';

        elsif (SS_in= '0') then -- if joystick is enabled
            if (sclk_counter = sclk_speed) then
                sclk_counter <= x"0000";
                if (SCLK_in = '1') then
                    SCLK_in <= '0';
                else 
                    if(bits_sent = 40) then -- set the last falling edge
                        SCLK_in <= '0';
                    else 
                        bits_sent <= bits_sent + 1;
                        SCLK_in <= '1';
                    end if;
                end if;
            else
                sclk_counter <= sclk_counter + 1;          
            end if;
        end if;
    end if;
end process;
end architecture;





