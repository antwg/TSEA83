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
    x"0800000A", -- ldi a, 10
    x"08100004", -- ldi b, 4
    x"0F010000", -- sub a, b ; a = 6
    x"0E000002", -- addi a, 2 ; a = 8
    x"10100002", -- subi b, 2 ; b = 2
    x"0D010000", -- add a, b ; a = 10
    x"20000000", -- lsrs a ; a = 5
    x"1C000003", -- muli, a, 3 ; a = 15
    x"1F100000", -- lsls b ; b = 4
    x"1B010000", -- mul a, b ; a = 60
    x"0B100000", -- st b, a ; store a = 60 on addr b = 4
    x"08000000", -- ldi a, 0 ; a = 0
    x"09010000", -- ld a, b ; a = 60
    x"1E00FFFF", -- mulsi a, -1 ; a = -60 
    x"14000007", -- andi a, 7  ; a = 4
    x"08100008", -- ldi b, 8
    x"15010000", -- or a, b ; a = 12  
    x"00000000", -- nop
    x"0100FFFF", -- rjmp -1


    
    
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
