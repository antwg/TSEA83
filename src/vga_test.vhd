library IEEE;
use IEEE.STD_LOGIC_1164.ALL;            -- basic IEEE library
use IEEE.NUMERIC_STD.ALL;               -- IEEE library for the unsigned type
                                        -- and various arithmetic operations
entity vga_test is
  port ( clk	           : in std_logic;                         -- system clock
  rst                    : in std_logic;                         -- reset
  Hsync	                 : out std_logic;                        -- horizontal sync
  Vsync	                 : out std_logic;                        -- vertical sync
  vgaRed	               : out	std_logic_vector(2 downto 0);    -- VGA red
  vgaGreen               : out std_logic_vector(2 downto 0);     -- VGA green
  vgaBlue	               : out std_logic_vector(2 downto 1)
  --spriteOut       : out unsigned(14 downto 0);
  );   
end vga_test;

architecture Behavioral of vga_test is

  component VGA_MOTOR
    port ( clk	            : in std_logic;                         -- system clock
           rst              : in std_logic;                         -- reset
           Hsync	          : out std_logic;                        -- horizontal sync
           Vsync	          : out std_logic;                        -- vertical sync
           vgaRed	          : out	std_logic_vector(2 downto 0);     -- VGA red
           vgaGreen         : out std_logic_vector(2 downto 0);     -- VGA green
           vgaBlue	        : out std_logic_vector(2 downto 1);
           
           spriteWrite      : in  std_logic;            -- 1 -> writing   0 -> reading
           spriteType       : in  unsigned(2 downto 0); -- the order the sprite is locatet in "spriteMem"
           spriteListPos    : in  unsigned(4 downto 0); -- where in the "spriteList" the sprite is stored
           spriteX          : in  unsigned(6 downto 0); -- cordinates for sprite. Note: the sprite cord is divided by 8	
           spriteY          : in  unsigned(5 downto 0)
           
           );    -- VGA blue
           
  end component;

begin

    U0: VGA_MOTOR port map(
      clk => clk,
      rst => rst,
      vgaRed => vgaRed,
      vgaGreen => vgaGreen,
      vgaBlue => vgaBlue,
      Hsync => Hsync,
      Vsync => Vsync,

      spriteWrite => '1',  
      spriteType => "011",  
      spriteListPos => "00000", 
      spriteX => "0000000", 
      spriteY => "000000"       
      );

end Behavioral;

