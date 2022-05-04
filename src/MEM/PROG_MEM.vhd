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

	type PM_t is array(0 to 1024) of unsigned(31 downto 0);
	constant PM_c : PM_t := (
		x"00000000", -- NOP
		x"0810001F", -- LDI b,$001F  
		x"0820401F", -- LDI c,$401F 
		x"0830FC00", -- LDI d,$FC00 
		x"0840FC01", -- LDI e,$FC01
		x"0B310000", -- ST d,b
		x"0B420000", -- ST e,c
		x"0810001F", -- LDI b,$001F
		x"0820401F", -- LDI c,$401F 
		x"0830FC02", -- LDI d,$FC02
		x"0840FC03", -- LDI e,$FC03
		x"0B310000", -- ST d,b
		x"0B420000", -- ST e,c
		x"0850FC1F", -- LDI f,$FC1F
		x"09050000", -- LD a,f
		x"0A500000", -- STI f,$0000
		x"0100FFFE", -- RJMP -2
		
		

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
