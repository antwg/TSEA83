library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity PROG_MEM is
	Port( 	clk, we : in std_logic;
            addr : in unsigned(15 downto 0);
		    data_out : out unsigned(31 downto 0);
		    wr_addr : in unsigned(15 downto 0);
		    wr_data : in unsigned(31 downto 0));
end PROG_MEM;

architecture func of PROG_MEM is

	type PM_t is array(0 to 256) of unsigned(31 downto 0);
	constant PM_c : PM_t := (
		x"08F00000", -- LDI P,0
		x"08E00000", -- LDI O,0
		x"0800FDE8", -- LDI a, 65000
		x"10000001", -- SUBI a, 1
		x"12000000", -- CMPI a, 0
		x"0300FFFE", -- BNE -2
		x"08F08000", -- LDI P, 32768 ; load enable bit 1000000000000000
		x"081001F4", -- LDI b, 500 
		x"08000FA0", -- LDI a, 4000 
		x"10000001", -- SUBI a, 1
		x"12000000", -- CMPI a, 0
		x"0300FFFE", -- BNE -2
		x"10100001", -- subi b, 1
		x"12100000", -- CMPI b, 0
		x"0300FFFA", -- BNE -6
		x"14F07FFF", -- ANDI p, 32767 ; disable joystick 0111111111111111
		x"0CF20000", -- COPY p,c ; move read bits  to c
		x"0100FFE9", -- RJMP -23 ;start again 
		x"00000000", -- NOP
		x"0100FFFF", -- RJMP -1 ; just in case we loop at the end
		
		
										others => (others => '0')
	);

	signal PM : PM_t := PM_c;

begin
  	process(clk)
        begin
          if rising_edge(clk) then
            if we = '1' then
              PM(to_integer(wr_addr)) <= wr_data;
            end if;
          end if;
  	end process;

	data_out <= PM(to_integer(addr)); -- much hardware with asyn read, same in DM
end func;
