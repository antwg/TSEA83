library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity pipeCPU_tb is
end pipeCPU_tb;

architecture sim of pipeCPU_tb is

component pipeCPU is
	port(
		clk : in std_logic;
		rst : in std_logic;
		UART_in : in std_logic;

		vgaRed		    : out std_logic_vector(2 downto 0);
        vgaGreen	    : out std_logic_vector(2 downto 0);
        vgaBlue		    : out std_logic_vector(2 downto 1);
        Hsync		    : out std_logic;
        Vsync		    : out std_logic);
end component;

	signal clk : std_logic;
	signal rst : std_logic;
	signal rx : std_logic;

	signal vgaRed  : std_logic_vector(2 downto 0);
	signal vgaGreen  : std_logic_vector(2 downto 0);
	signal vgaBlue  : std_logic_vector(1 downto 0);
  
	signal Hsync	  : std_logic;                        -- horizontal sync
	signal Vsync	  : std_logic;  
  

begin

	U0 : pipeCPU port map(
		clk => clk,
		rst => rst,
		UART_in => rx,
		
		vgaRed	=> vgaRed,    
        vgaGreen => vgaGreen,	    
        vgaBlue => vgaBlue,  
		Hsync => Hsync,
		Vsync => Vsync	     );

	process
	begin

		clk <= '0';
		wait for 5 ns;
		clk <= '1';
		wait for 5 ns;

	end process;

	rst <= '1', '0' after 7 ns;

end architecture;
