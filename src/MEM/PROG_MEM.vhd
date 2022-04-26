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
		x"08200002", -- LDI c,2 ; set a mosi bit xxxx0010 this is later cleared so that the remaning sent is 0
		x"08300028", -- LDI d,40
		x"0840000A", -- LDI e,10
		x"08500001", -- LDI f,1
		x"08000008", -- LDI a,8 ;xxxx1000
		x"16F00001", -- ORI p,1 ; set SS high, xxxx0001
		x"08000008", -- LDI a,8 ;xxxx1000 mask for SCLK bit 
		x"130F0000", -- AND a,p ; mask out SCLK
		x"12000004", -- CMPI a,4 ; check if SCLK was high
		x"0300FFFD", -- BNE -3;LOOP_START
		x"080000C8", -- LDI a,200 ; load with the wait amount
		x"10000001", -- SUBI a,1
		x"12000000", -- CMPI a,0
		x"0300FFFE", -- BNE -2;LOOP_START2 ; when looped "a" amount then stop  
		x"08100004", -- LDI b,4 ; xxxx0100 ; mask for MISO bit (joystick output)
		x"131F0000", -- AND b,p ; now we get the bit from the joystick
		x"20110000", -- LSRS b,b ; move the MISO bit to the least significant bit
		x"20110000", -- LSRS b,b
		x"14F0FFFB", -- ANDI p,65531 ; clear the MOSI bit  1111111111111011 = 65,531 
		x"16F00000", -- ORI p,c ; set the mosi bit to the value in c
		x"14200000", -- ANDI c,0; the first of the 40 bits send to the joystick should be 1 and the rest 0 
		x"10300001", -- SUBI d,1 ; all bits counter
		x"12400000", -- CMPI e,0
		x"02000004", -- beq 4;e_done ; if we have revied the bits for x then skip
		x"10400001", -- subi e,1 ; x bit counter 
		x"15510000", -- OR f,b;
		x"1F550000", -- LSLS f,f ; move the  bits for the x 
		x"12100000", -- CMPI b,0
		x"0300FFE7", -- bne -25;joystick_loop ; when b is not 0 jump to the start
		x"14F0FFFE", -- ANDI p,65534 ; set SS low, xxxx1110 
		x"0100FFE2", -- RJMP -30-bash-4.2$ 
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
