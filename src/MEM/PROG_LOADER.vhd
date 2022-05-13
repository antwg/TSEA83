library IEEE;
use IEEE.std_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.all;

entity PROG_LOADER is
    Port (  clk, rst, rx, boot_en : in std_logic;
            done, we : out std_logic;
            addr : out unsigned(15 downto 0);
            data_out : out unsigned(31 downto 0));
end PROG_LOADER;

architecture func of PROG_LOADER is
    -- holds one byte (4th of instructions), fetched from UART rx
    signal byteReg : unsigned(9 downto 0) := (others => '0');

    -- holds a full instruction, where byteReg stores each byte
    signal instrReg : unsigned(31 downto 0) := (others => '0');

    -- sync for rx signal
    signal rx1, rx2 : std_logic := '1';

    -- sync for write enable signal (to PM)
    signal we_en, we_en1, we_en2 : std_logic := '0';

    -- shiftpulse for the byteReg shift register
    signal sp : std_logic := '0';

    -- is set when we've read one full instruction through UART
    signal fullInstr : std_logic := '0';

    -- is set to 1 when we've read up to EOF
    signal finished : std_logic := '0';

    -- which addr to write to in PM (increases every instruction fetch)
    signal addr_cnt_en : std_logic := '0';
    signal addr_cnt_out : unsigned(15 downto 0) := (others => '0');

    -- 868 counter, for syncing with the UART clock
    signal st_868_cnt_en  : std_logic := '0'; 	-- enable counter
    signal st_868_cnt_out : unsigned(10 downto 0) := (others => '0'); -- counter out

    -- char counter, keep tracks of the bits for the byte currently fetching
    signal st_10_cnt_out : unsigned(3 downto 0) := (others => '0'); -- counter out

    -- 4 counter, keep tracks on what in the instruction we're fetching (opcode et.c...)
    signal st_4_cnt_out : unsigned(1 downto 0) := (others => '0'); -- counter out

    -- 50 Mhz clock, each bit 8.68 us long
    constant max_cnt : unsigned(11 downto 0) := x"1A0"; 
begin
    -- syncing
    process(clk) begin
        if (rising_edge(clk)) then
            if (rst='1' or boot_en='0') then
                rx1 <= '1';
                rx2 <= '1';
                we_en1 <= '0';
                we_en2 <= '0';
            end if;

            if (finished='0' and boot_en='1') then
                -- sync rx
                rx1 <= rx;
                rx2 <= rx1;

                -- sync we
                we_en1 <= we_en;
                we_en2 <= we_en1;
            end if;
        end if;
    end process;

    -- all counters
    process(clk) begin
        if (rising_edge(clk)) then
            if (rst='1' or boot_en='0') then
                st_868_cnt_out <= (others => '0');
                st_10_cnt_out <= (others => '0');
                st_4_cnt_out <= (others => '0');
                addr_cnt_out <= (others => '0');

            elsif (finished='0') then
                -- start counting if we see a startbit
                if (st_868_cnt_en='0' and rx1='0' and rx2='1') then 
                    st_868_cnt_en <= '1';

                -- we've fetched a byte, wait for next startbit
                elsif (st_868_cnt_en='1' and st_868_cnt_out=max_cnt and st_10_cnt_out=9 and rx1='1') then
                    st_868_cnt_en <= '0';
                    st_868_cnt_out <= (others => '0');
                    st_10_cnt_out <= (others => '0');

                    -- we've also fetched a full instruction
                    if (st_4_cnt_out=3) then
                        st_4_cnt_out <= (others => '0');
                    -- or not
                    else
                        st_4_cnt_out <= st_4_cnt_out + 1;
                    end if;

                -- if we're still fetching the same byte
                elsif (st_868_cnt_en='1') then

                    -- reset the 868 counter when we reach max_cnt, else just count
                    if (st_868_cnt_out=max_cnt) then
                        st_868_cnt_out <= (others => '0');
                    else
                        st_868_cnt_out <= st_868_cnt_out + 1;
                    end if;

                    -- we've fetched one bit
                    if (st_868_cnt_out=max_cnt and st_10_cnt_out < 9) then
                        st_10_cnt_out <= st_10_cnt_out + 1;
                    end if;

                end if;

                if (addr_cnt_en='1') then
                    addr_cnt_out <= addr_cnt_out + 1;
                end if;
            end if;
        end if;
    end process;

    -- 10 bit shift register (holds the fetched byte + stop/start bits, 4th of an instruction)
    process(clk) begin
        if (rising_edge(clk)) then
            if (rst='1' or finished='1') then
                byteReg <= (others => '0');
            elsif (sp='1') then
                byteReg <= byteReg srl 1;
                byteReg(9) <= rx2;
            else
                byteReg <= byteReg;
            end if;
        end if;
    end process;

    -- 32 bit shift register (holds one whole instruction)
    process(clk) begin
        if (rising_edge(clk)) then
            if (rst='1') then
                fullInstr <= '0';
                instrReg <= (others => '0');
                finished <= '0';
            end if;

            -- only do stuff when we're at an end of a sent byte
            if (st_868_cnt_out=max_cnt and st_10_cnt_out=9) then

                -- add to instruction register depending on what part of the instruction
                -- we're currently fetching
                if (st_4_cnt_out=0) then -- opcode
                    fullInstr <= '0'; -- we're reading a new instruction now

                    instrReg(31 downto 24) <= byteReg(8 downto 1);

                    -- opcode 0xFF signals EOF
                    if (byteReg(8 downto 1) = x"FF") then
                        finished <= '1';
                    end if;
                elsif (st_4_cnt_out=1) then -- registers
                    instrReg(23 downto 16) <= byteReg(8 downto 1);
                elsif (st_4_cnt_out=2) then -- second part of 16bit constant
                    instrReg(7 downto 0) <= byteReg(8 downto 1);
                elsif (st_4_cnt_out=3) then -- first part of 16bit constant
                    instrReg(15 downto 8) <= byteReg(8 downto 1);
                    fullInstr <= '1'; -- we've read a full instruction now
                end if;
            end if;
        end if;
    end process;

    -- shift the byte shiftregister halfway through a sent bit
    sp <= '1' when st_868_cnt_out=208 else '0';

    -- increase addr after a write
    addr_cnt_en <= '1' when (we_en1='1' and we_en2='0') else '0';

    -- write current instruction to memory when a full one has
    -- been read, and the shift register has been updated with it (e.g. st_4_cnt_out=0)
    we_en <= '1' when (st_4_cnt_out=0 and fullInstr='1') else '0';

    -- one pulse the write enable signal
    we <= '1' when (we_en1='1' and we_en2='0') else '0'; 

    -- passive passing
    data_out <= instrReg(31 downto 0);
    addr <= addr_cnt_out;
    done <= finished;
end func;
