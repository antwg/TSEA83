library IEEE;
use IEEE.std_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.all;

entity PROG_LOADER is
	Port ( clk, rst, rx : in std_logic;
	       done, we : out std_logic;
	       addr : out unsigned(15 downto 0);
	       data_out : out unsigned(31 downto 0));
end PROG_LOADER;

architecture func of PROG_LOADER is
	signal byteReg : unsigned(9 downto 0) := (others => '0');
	signal instrReg : unsigned(31 downto 0) := (others => '0');
	signal rx1, rx2 : std_logic; -- synkvippor
	signal sp : std_logic := '0';
	signal w_instr : std_logic := '0';
    signal ke_done : std_logic := '0';
    signal we_en : std_logic := '0';
    signal we_en1 : std_logic := '0';
    signal we_en2 : std_logic := '0';
    signal fullInstr : std_logic := '0';

	-- addr counter
	signal addr_cnt_en : std_logic := '0';
	signal addr_cnt_rst : std_logic := '0';
	signal addr_cnt_out : unsigned(15 downto 0);

	-- 868 counter
   	signal st_868_cnt_en  : std_logic := '0'; 	-- enable counter
    signal st_868_cnt_rst : std_logic := '0'; 	-- reset counter
    signal st_868_cnt_out : unsigned(10 downto 0) := B"00000000000"; -- counter out

    -- char counter
   	signal st_10_cnt_en  : std_logic := '0'; 	-- enable counter
    signal st_10_cnt_rst : std_logic := '0'; 	-- reset counter
    signal st_10_cnt_out : unsigned(3 downto 0) := B"0000"; -- counter out

	-- 4 counter
   	signal st_4_cnt_en  : std_logic := '0'; 	-- enable counter
    signal st_4_cnt_rst : std_logic := '0'; 	-- reset counter
    signal st_4_cnt_out : unsigned(1 downto 0) := B"00"; -- counter out
begin
	-- control unit
	process(clk) begin
	    if rising_edge(clk) then
            -- sync rx
			rx1 <= rx;
			rx2 <= rx1;

            -- sync we
            we_en1 <= we_en;
            we_en2 <= we_en1;

            -- start counting as soon as we see a startbit
            -- then it never has to stop until whole program has been read
            if (rx1='0' and rx2='1' and st_868_cnt_en='0') then -- start bit
                st_868_cnt_en <= '1';
            end if;
    
	    end if;
	end process;

	-- all counters
	process(clk) begin
	    if rising_edge(clk) and ke_done='0' then
		    if (st_868_cnt_rst='1' or rst='1') then
                st_868_cnt_out <= (others => '0');
		    elsif (st_868_cnt_en='1') then
                st_868_cnt_out <= st_868_cnt_out + 1;
		    end if;

		    if (st_10_cnt_rst='1' or rst='1') then
                st_10_cnt_out <= (others => '0');
		    elsif (st_10_cnt_en='1') then
                st_10_cnt_out <= st_10_cnt_out + 1;
		    end if;

		    if (st_4_cnt_rst='1' or rst='1') then
                st_4_cnt_out <= (others => '0');
		    elsif (st_4_cnt_en='1') then
                st_4_cnt_out <= st_4_cnt_out + 1;
		    end if;

		    if (addr_cnt_rst='1' or rst='1') then
                addr_cnt_out <= (others => '0');
		    elsif (addr_cnt_en='1') then
                addr_cnt_out <= addr_cnt_out + 1;
		    end if;
	    end if;
	end process;
	
	-- 10 bit shift register (holds one byte, 4th of an instruction)
	process(clk) begin
	    if rising_edge(clk) then
            if sp='1' then
                byteReg <= byteReg srl 1;
                byteReg(9) <= rx2;
            else
                byteReg <= byteReg;
            end if;
	    end if;
	end process;
	
	-- 32 bit shift register (holds one whole instruction)
	process(clk) begin
	    if rising_edge(clk) then
            if st_4_cnt_en='1' then
                if st_4_cnt_out=0 then -- opcode
                    fullInstr <= '0'; -- we're reading a new instruction now

                    instrReg(31 downto 24) <= byteReg(8 downto 1);

                    -- opcode 0xFF signals EOF
                    if (byteReg(8 downto 1) = B"11111111") then
                        ke_done <= '1';
                    end if;
                elsif st_4_cnt_out=1 then -- registers
                    instrReg(23 downto 16) <= byteReg(8 downto 1);
                elsif st_4_cnt_out=2 then -- second part of 16bit constant
                    instrReg(7 downto 0) <= byteReg(8 downto 1);
                elsif (st_4_cnt_out=3) then -- first part of 16bit constant
                    instrReg(15 downto 8) <= byteReg(8 downto 1);
                    fullInstr <= '1'; -- we've read a full instruction now
                end if;
            else
                instrReg <= instrReg;
            end if;
	    end if;
	end process;

	-- shift the byte shiftregister halfway through a sent bit
	sp <= '1' when st_868_cnt_out=434 else '0';

    -- we reset 10 cnt when 868 resets, we've read one char
	st_10_cnt_en <= '1' when st_868_cnt_rst='1' else '0';

    -- we count everytime we've gotten one byte
    st_4_cnt_en <= '1' when st_10_cnt_out=10 else '0';

    -- reset counters
	st_868_cnt_rst <= '1' when st_868_cnt_out=868 else '0';
	st_10_cnt_rst <= '1' when st_10_cnt_out=10 else '0';

    -- increase addr after a write
	addr_cnt_en <= '1' when (we_en1='1' and we_en2='0') else '0';

    -- write current instruction to memory when a full one has
    -- been read, and the shift register has been updated with it (e.g. st_4_cnt_out=0)
    we_en <= '1' when (st_4_cnt_out=0 and fullInstr='1') else '0';

    -- passive passing
	data_out <= instrReg(31 downto 0);
    we <= '1' when (we_en1='1' and we_en2='0') else '0'; -- one pulse the we signal
	addr <= addr_cnt_out;
    done <= ke_done;
end func;
