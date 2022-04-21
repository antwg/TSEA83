library IEEE;
use IEEE.STD_LOGIC_1164.ALL;            -- basic IEEE library
use IEEE.NUMERIC_STD.ALL;               -- IEEE library for the unsigned type
                                        -- and various arithmetic operations
entity vga_tb is
end vga_tb;

architecture behavior of vga_tb is

  component vga_test
    port ( clk	          : in std_logic;                         -- system clock
           rst            : in std_logic;                         -- reset
           Hsync	  : out std_logic;                        -- horizontal sync
           Vsync	  : out std_logic;                        -- vertical sync
           vgaRed	  : out	std_logic_vector(2 downto 0);     -- VGA red
           vgaGreen       : out std_logic_vector(2 downto 0);     -- VGA green
           vgaBlue	  : out std_logic_vector(2 downto 1)
           
           );    -- VGA blue
           
  end component;

  signal clk : std_logic;
  signal rst : std_logic;

  signal vgaRed  : std_logic_vector(2 downto 0);
  signal vgaGreen  : std_logic_vector(2 downto 0);
  signal vgaBlue  : std_logic_vector(1 downto 0);

  signal Hsync	  : std_logic;                        -- horizontal sync
  signal Vsync	  : std_logic;  



  constant clk_period : time := 10 ns;

  begin

    U0: vga_test port map(
      clk => clk,
      rst => rst,
      vgaRed => vgaRed,
      vgaGreen => vgaGreen,
      vgaBlue => vgaBlue,
      Hsync => Hsync,
      Vsync => Vsync
  
      );      

    clk_process : process
      begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;

    rst <= '1', '0' after 25 ns;
end architecture;

