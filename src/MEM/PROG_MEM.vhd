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
		x"0810001F", -- LDI b,31   ;000000000000110
		x"0820201F", -- LDI c,8223 ;001000000011111
		x"0830FC00", -- LDI d,64512 ; FC00
		x"0840FC01", -- LDI e,64513 ; FC01
		x"0850FDE8", -- LDI f,65000 ; Inner counter
		x"08600028", -- LDI g,40   ; Outer counter
		x"0B310000", -- ST d,b
		x"0B420000", -- ST e,c
		x"09130000", -- LD b,d
		x"0E100001", -- ADDI b,1
		x"0B310000", -- ST d,b
		x"10500001", -- SUBI f,1
		x"0300FFFF", -- BNE -1
		x"0850FDE8", -- LDI f,65000
		x"10600001", -- SUBI g,1
		x"0300FFFC", -- BNE -4
		x"08600028", -- LDI g,40
		x"0100FFF7", -- RJMP -9
		
		
		
		

		
		
		

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
