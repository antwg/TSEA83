library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


--  ===================================================================================
--  								Define Module, Inputs and Outputs
--  ===================================================================================
entity joystick is
    Port ( CLK : in  STD_LOGIC;								-- 100Mhz onboard clock
           RST : in  STD_LOGIC;								-- Button D
           SW : in  STD_LOGIC_VECTOR (2 downto 0);		-- Switches 2, 1, and 0
           joy_out : out unsigned (1 downto 0);
           finished : out std_logic
   ); -- Cathodes for Seven Segment Display
end joystick;

architecture Behavioural of joystick is
component PmodJSTK_Demo is
    Port ( CLK : in  STD_LOGIC;								-- 100Mhz onboard clock
           RST : in  STD_LOGIC;								-- Button D
           MISO : in  STD_LOGIC;								-- Master In Slave Out, JA3
           SW : in  STD_LOGIC_VECTOR (2 downto 0);		-- Switches 2, 1, and 0
           SS : out  STD_LOGIC;								-- Slave Select, Pin 1, Port JA
           MOSI : out  STD_LOGIC;							-- Master Out Slave In, Pin 2, Port JA
           SCLK: out  STD_LOGIC;							-- Serial Clock, Pin 4, Port JA
           LED : out  STD_LOGIC_VECTOR (2 downto 0));	-- LEDs 2, 1, and 0
    end component;


    signal MISO_master : STD_logic;         -- sets the leds on the joystick
    signal MOSI : STD_LOGIC;							-- Master Out Slave In, Pin 2, Port JA
    signal SCLK: STD_LOGIC;							-- Serial Clock, Pin 4, Port JA
    signal LED : STD_LOGIC_VECTOR (2 downto 0);	-- LEDs 2, 1, and 0
    signal SS : STD_LOGIC;								-- Slave Select, Pin 1, Port JA
    signal joystick_value : unsigned(39 downto 0);
    signal joystick_shift: unsigned(40 downto 0);
    signal joystick_shift_in : unsigned(40 downto 0);
    signal joystick_value_in : unsigned(39 downto 0);
    alias X_high : unsigned(7 downto 0) is joystick_value (39 downto 32);
    alias X_low : unsigned(7 downto 0) is joystick_value (31 downto 24);
    alias Y_high : unsigned(7 downto 0) is joystick_value (23 downto 16);
    alias Y_low : unsigned(7 downto 0) is joystick_value (15 downto 8);
    alias buttons : unsigned(7 downto 0) is joystick_value (7 downto 0);

    signal joystick_sync_cnt: unsigned(7 downto 0) := (others => '0');
    signal joystick_recived: std_logic := '0';
begin

-- read from mosi to get the joystick values 
-- write to miso to set LED on joystick, the last two bits in the first byte
PmodJTK_Demo : PmodJSTK_Demo port map(
    CLK => CLK,
    RST => RST,
    MISO => joystick_shift_in(39),
    SW => SW,
    MOSI => MOSI,
    SCLK=> SCLK,
    LED  => LED ,
    SS => SS
);

joystick_shift <= joystick_value&MOSI;
joystick_shift_in <= joystick_value_in&'0';
finished <= joystick_recived;

process(clk)
begin 
    if rising_edge(clk) then
       if (SCLK = '1') then
                    
        if ( joystick_sync_cnt = 39 ) then -- when counter has counted 40 times all bytes have been read
                joystick_sync_cnt <= x"00";
                joystick_value_in <= "0000001100000000000000000000000000000000";
                joystick_recived <= '1';
            else
                joystick_recived <= '0';
                joystick_value_in <=  joystick_shift_in(39 downto 0); -- shift left and put mosi on lowest
                joystick_value <=  joystick_shift(39 downto 0); -- shift left and put mosi on lowest
                joystick_sync_cnt <= joystick_sync_cnt + 1;
            end if;    
        end if;
    end if;
end process;

process(clk)
begin 
    if rising_edge(clk) then

        if (joystick_recived = '1') then
            if (X_high > 250) then 
                joy_out <= "00";
                --seven sgement  up
            elsif (X_low > 250) then 
                -- seven seg down
                joy_out <= "01";
            elsif (Y_high > 250) then 
                -- seven seg left
                joy_out <= "10";
            elsif (Y_low > 250) then 
                -- sven seg right
                joy_out <= "11";
            end if;
        end if;
    end if;
end process;






end architecture;





