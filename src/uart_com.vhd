library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity UART_COM is
	port (clk, rst : in std_logic;
          bit_out : out std_logic;
          send : in std_logic;
          send_byte : in unsigned(7 downto 0);	
          sent : out std_logic);
end UART_COM;

architecture func of UART_COM is
    signal tx_byte : unsigned(7 downto 0) := (others => '0'); -- the byte to send
    signal done : std_logic := '1'; -- if we've sent the whole byte

    signal rp : std_logic := '0'; -- rotate pulse
    signal output : std_logic := '1'; -- output bit
    signal start_bit : std_logic := '0'; -- if we're sending start bit
    signal stop_bit : std_logic := '0'; -- if we're sending stop bit
    
    -- 868 counter
    signal st_868_cnt_en  : std_logic := '0';   -- enable counter
    signal st_868_cnt_rst : std_logic := '0';   -- reset counter
    signal st_868_cnt_out : unsigned(10 downto 0) := (others => '0'); -- counter out

    -- byte counter
    signal st_8_cnt_en  : std_logic := '0';    -- enable counter
    signal st_8_cnt_rst : std_logic := '0';    -- reset counter
    signal st_8_cnt_out : unsigned(3 downto 0) := (others => '0'); -- counter out
begin
	
   -- all counters
    process(clk) begin
        if (rising_edge(clk)) then
            if (st_868_cnt_rst='1' or rst='1' or done='1') then
                st_868_cnt_out <= (others => '0');
            elsif (st_868_cnt_en='1') then
                st_868_cnt_out <= st_868_cnt_out + 1;
            end if;

            if (st_8_cnt_rst='1' or rst='1' or done='1') then
                st_8_cnt_out <= (others => '0');
            elsif (st_8_cnt_en='1') then
                st_8_cnt_out <= st_8_cnt_out + 1;
            end if;
        end if;
    end process;

    -- accepts new input and handles rotation of byte to send
    process(clk) begin
        if rising_edge(clk) then
            -- accept a new transmission and start sending start bit
            if (done='1' and send='1') then
                tx_byte <= send_byte;
                done <= '0';
                start_bit <= '1';
                stop_bit <= '0';
            -- we've sent the start bit, start sending the data
            elsif (st_868_cnt_out=868 and start_bit='1') then
                start_bit <= '0';
            -- tell comp to send an stop bit before saying we're done
            elsif (st_8_cnt_out=8 and done='0') then
                start_bit <= '0';
                stop_bit <= '1';
            -- if we've sent the stop bit, then we're done
            elsif (st_868_cnt_out=868 and stop_bit='1') then
                stop_bit <= '0';
                done <= '1';
            elsif (rp='1') then -- handles rotation of the byte to send
                tx_byte <= shift_right(tx_byte, 1);
            end if;
        end if;
    end process;

    -- sets output to the correct bit
    -- TODO could make a st_10_cnt instead of 8 and regulate from that...
    process(clk) begin
        if rising_edge(clk) then
            if (start_bit='1') then
                output <= '0';
            elsif (stop_bit='1') then
                output <= '1';
            else
                output <= tx_byte(0);
            end if;
        end if;
    end process;

    rp <= '1' when st_868_cnt_rst='1' else '0';

    st_868_cnt_rst <= '1' when st_868_cnt_out=868 else '0';
    st_868_cnt_en <= '1' when done='0' else '0';
    st_8_cnt_rst <= '1' when st_8_cnt_out=8 else '0';
    st_8_cnt_en <= '1' when (done='0' and
                             st_868_cnt_rst='1' and
                             stop_bit='0' and
                             start_bit='0') else '0';

    sent <= '1' when done='1' else '0';
    bit_out <= output;
end architecture;
