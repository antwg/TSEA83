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
		x"08002820", -- LDI a,10272 ; 0010100000100000
		x"08102FFF", -- LDI b,12287 ; 0010111111111111
		x"082023CF", -- LDI c,9167  ; 0010001111001111
		x"0830FC01", -- LDI d,64513 ; The register to write to
		x"0840FC02", -- LDI e,64514 ; The register to write to
		x"0850FC03", -- LDI f,64515 ; The register to write to
		x"0B300000", -- ST d,a
		x"0B410000", -- ST e,b
		x"0B520000", -- ST f,c
		x"00000000", -- NOP
		x"0100FFFF", -- RJMP -1
		

		
		
		
		
		

		
	
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
