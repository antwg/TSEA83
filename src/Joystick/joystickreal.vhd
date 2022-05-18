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
    -- the amount of bits which have been transfered 
    signal bits_sent : unsigned(6 downto 0) := (others => '0');
    -- the counter for the lenght of a SCLK pulse
    signal sclk_counter : unsigned (15 downto 0) := (others => '0');
    -- data from the joystick
    signal x: unsigned(9 downto 0) := (others => '0');   
    signal y: unsigned(9 downto 0):= (others => '0');
    signal btns: unsigned(2 downto 0):= (others => '0');  
    -- onepulsing of the clk
    signal SCLK_old : std_logic := '0'; 
    signal fall_edge_SCLK_enp : std_logic := '0';
    signal rise_edge_SCLK_enp : std_logic := '0';
    -- Data which is sent to the joystick 
    signal MOSI_out : unsigned(7 downto 0):= "10000000";
    -- how much sclk_counter should count to 
    constant sclk_speed : unsigned (15 downto 0) := x"07CF"; -- 1999
    -- The leds on the joystick, 1 means that is will be on
    signal leds : unsigned(1 downto 0):= "11";
    -- inner signals used to set the respective outer signal
    signal SS_in,MOSI_in,SCLK_in : std_logic;

    -- SS, Slave Select, Pin 1, Port JA
    -- MOSI, Master Out Slave In, Pin 2, Port JA;
    -- MISO, Pin 3 master in slave out
    -- SCLK, Serial Clock, Pin 4, Port JA

    begin


SS <= SS_in;
MOSI <= MOSI_in;
SCLK <= SCLK_in;

--onepulsing
fall_edge_SCLK_enp <= (not SCLK_in) and not SCLK_old;
rise_edge_SCLK_enp <= (SCLK_in) and SCLK_old;

-- the joystick is meant to go start when enable is 1 
-- and SS enables the joystick when it is 0
SS_in <= not enable; -- ss is the opposite of what makes sense, 0 is enable 1 is disable

-- data sent out from the joystick
data_out <= x&y&btns;

-- the bit sent out to the joystick
MOSI_in <= MOSI_out(7);


-- ########bit controlling########
-- Handle the data from and to the joystick
-- The transfer takes 40 bits where the bits from the joystick is
-- divided as: 
--
-- xxxxxxxx------xxyyyyyyyy------yy-----bbb
-- 0000000000000000000000000000000000000000 
-- where x,y is the joystick x,y values and b stands for buttons
-- 
-- Every transmission the led bits are decreased which causes a
-- pattern on the leds of the joystick. 
-- The LED bits are the last bit of first byte.
-- reading is done on the falling edge of SCLK 
-- while writing is done on the rising edge.
process(clk) begin
    --send data to joystick
    if rising_edge(clk) then
        SCLK_old <= not SCLK_in;
        -- when no bits have been sent ready the led data for the next transmission 
        if (bits_sent = 0) then
            MOSI_out <= "100000"&leds;
        -- write to the joystick
        elsif (rise_edge_SCLK_enp = '1' and bits_sent /= 1) then
            MOSI_out <= MOSI_out(6 downto 0)&'0';
        end if;
       
        -- read from the joystick
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
                -- buttons data
            elsif (bits_sent = 38) then
                btns(2) <= MISO;
            elsif (bits_sent = 39) then
                btns(1) <= MISO;
            elsif (bits_sent = 40) then
                btns(0) <= MISO;
                -- the done bits tells when we have got/sent all 40 bits
                done <= '1';
                --changing the leds causes MOSI_out to send a blinking 
                -- pattern on the joystick
                leds <= leds - 1;
                end if;
                -- if ss is disabeld "1" or rst then
                -- reset all the values
        elsif(SS_in = '1' or rst = '1') then
            x <= "0000000000";
            y <= "0000000000";
            btns <= "000";
        end if;
            -- when all bits are not sent set the done bit low
        if (bits_sent /= 40) then
            done <= '0';
        end if;

    end if;
end process;

-- ssclk_counter counts up to the desiresed sclk_speed and when that is
-- reached SCLK goes low or high which means that rising edge to rising edge
-- takes 2 * sclk_counter.
-- After every transmission SS/enable needs to be set low otherwise
-- new data does not come.

process(clk) begin 
    if rising_edge(clk) then
        if (SS_in = '1' or RST = '1') then -- ss = 1 means joystick is disabled
            sclk_counter <= x"0000";
            bits_sent <= "0000000";
            SCLK_in <= '0';

        elsif (SS_in= '0') then -- if joystick is enabled
            if (sclk_counter = sclk_speed) then
                sclk_counter <= x"0000";
                -- set SCLK to low if it is high and low if high.
                if (SCLK_in = '1') then
                    SCLK_in <= '0';
                else 
                    if(bits_sent = 40) then -- Set the last falling edge since it dissapears otherwise.
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





