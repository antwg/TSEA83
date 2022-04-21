-- VGA MOTOR
-- 12-apr-2022
-- Version 1.1

-- How to use:
--  SpriteList:
--    the spiteList contains the information about the sprites. The list has a length of 32 -> Max of 32 sprites at a time.
--    To change a sprite:
--      spriteWrite   -> set to 1 to write
--      spriteType    -> set to the number the sprite represent
--        - 001: Space ship
--        - 002: Big asteroid
--      spriteListPos -> where in the list the sprite data is written
--      spriteX       -> the location of the top left corner of the sprite
--      spriteY     
--    To read from the sprite list:
--      spriteWrite   -> set to 0 (should be 0 in defult)
--      spriteListPos -> where the sprite to read is located
--      spriteOut     -> The output informantion is sent here.
--      


-- library declaration
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;            -- basic IEEE library
use IEEE.NUMERIC_STD.ALL;               -- IEEE library for the unsigned type


-- entity
entity VGA_MOTOR is
  port ( clk			: in std_logic;
	rst		        	: in std_logic;
	vgaRed		      : out std_logic_vector(2 downto 0);
	vgaGreen	      : out std_logic_vector(2 downto 0);
	vgaBlue		      : out std_logic_vector(2 downto 1);
	Hsync		        : out std_logic;
	Vsync		        : out std_logic;

  -- When changing sprite mem
  spriteWrite     : in  std_logic;            -- 1 -> writing   0 -> reading
  spriteType      : in  unsigned(2 downto 0); -- the order the sprite is locatet in "spriteMem"
  spriteListPos   : in  unsigned(4 downto 0); -- where in the "spriteList" the sprite is stored
  spriteX         : in  unsigned(6 downto 0); -- cordinates for sprite. Note: the sprite cord is divided by 8	
  spriteY         : in  unsigned(6 downto 0);	
  spriteOut       : out unsigned(16 downto 0)
  );
  

end VGA_MOTOR;


-- architecture
architecture Behavioral of VGA_MOTOR is

    signal	Xpixel	        : unsigned(9 downto 0);       -- Horizontal pixel counter
    signal	Ypixel	        : unsigned(9 downto 0);		    -- Vertical pixel counter
    signal	ClkDiv	        : unsigned(1 downto 0);		    -- Clock divisor, to generate 25 MHz signal
    signal	Clk25		        : std_logic;		              -- One pulse width 25 MHz signal
		
    signal 	tilePixel       : unsigned(3 downto 0);	      -- Tile pixel data
    signal 	outputPixel_4bit : unsigned(3 downto 0);
    signal 	outputPixel     : std_logic_vector(7 downto 0);		
    signal	tileAddr	      : unsigned(10 downto 0);	    -- Tile address (temporary varible)

    signal blank            : std_logic;                  -- blanking signal
    signal tileListData     : unsigned(7 downto 0);
    signal sprite1          : std_logic;   
 
    signal sprite0pix        : unsigned(3 downto 0); 
    signal sprite1pix        : unsigned(3 downto 0); 
    signal sprite2pix        : unsigned(3 downto 0); 
    signal sprite3pix        : unsigned(3 downto 0); 
    signal sprite4pix        : unsigned(3 downto 0); 
    signal sprite5pix        : unsigned(3 downto 0); 
    signal sprite6pix        : unsigned(3 downto 0); 
    signal sprite7pix        : unsigned(3 downto 0); 
    signal sprite8pix        : unsigned(3 downto 0); 
    signal sprite9pix        : unsigned(3 downto 0); 
    signal sprite10pix       : unsigned(3 downto 0); 
    signal sprite11pix       : unsigned(3 downto 0); 
    signal sprite12pix       : unsigned(3 downto 0); 
    signal sprite13pix       : unsigned(3 downto 0); 
    signal sprite14pix       : unsigned(3 downto 0); 
    signal sprite15pix       : unsigned(3 downto 0); 

	

    -- creating tile mem
    type ram_1 is array (0 to 400) of unsigned(7 downto 0);
    signal tileList : ram_1 := (  32  => x"01", -- Blue star
                                  138 => x"01",
                                  204 => x"01",

                                  44  => x"02", -- White star
                                  75  => x"02",
                                  105 => x"02",
                                  115 => x"02",
                                  217 => x"02",
                                  230 => x"02",

                                  others => (others => '0'));

    type ram_2 is array (0 to 2047) of unsigned(3 downto 0);
    signal tileMem : ram_2 := ( x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",   -- Void (black)   
                                x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",
                                x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",
                                x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",
                                x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",
                                x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",
                                x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",
                                x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",
    
                                x"0",x"0",x"0",x"6",x"0",x"0",x"0",x"0",   -- star -blue
                                x"0",x"0",x"0",x"7",x"0",x"0",x"0",x"0",
                                x"0",x"0",x"5",x"7",x"5",x"0",x"0",x"0",
                                x"6",x"5",x"7",x"7",x"7",x"5",x"6",x"0",
                                x"0",x"0",x"5",x"7",x"5",x"0",x"0",x"0",
                                x"0",x"0",x"0",x"7",x"0",x"0",x"0",x"0",
                                x"0",x"0",x"0",x"6",x"0",x"0",x"0",x"0",
                                x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",

                                x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",   -- star -white 
                                x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",
                                x"0",x"0",x"0",x"0",x"7",x"0",x"0",x"0",
                                x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",
                                x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",
                                x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",
                                x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",
                                x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",
                              others => (others => '0'));

    -- creates the sprite memory

      -- spriteList(1)(26 downto 24) --> sprite_type
      -- spriteList(1)(23 downto 18) --> startX
      -- spriteList(1)(17 downto 12) --> startY
      -- spriteList(1)(11 downto 6 ) --> endX
      -- spriteList(1)(5 downto  0 ) --> endY

    -- Sprite mapping:
      -- 0 - blank
      -- 1 - space ship
      -- 2 - asteroid -big
    type ram_3 is array (0 to 31) of unsigned(30 downto 0);
    signal spriteList : ram_3 := ("001"&"0001000"&"0001000"&"0010111"&"0010111", 
                                  "011"&"1100000"&"1100000"&"1101111"&"1101111", 
                                  "011"&"0010000"&"0010000"&"0011111"&"0011111", 
                                  "010"&"0011000"&"0011000"&"0100111"&"0100111", 
                                  others => (others => '0'));

    -- 0 black/ transparent
    -- 1 gray-dark
    -- 2 gray-medium-dark
    -- 3 gray-medium-light
    -- 4 gray-light
    -- 5 neon-blue
    -- 6 neon-blue-light
    -- 7 white

    type ram_4 is array (0 to 2047) of unsigned(3 downto 0); -- Every sprite is 16x16 an there are 8 sprite -> 16x16x8=2048
    signal spriteMem : ram_4 := ( x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",  -- blank (no sprite)
                                  x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",
                                  x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",
                                  x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",
                                  x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",
                                  x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",
                                  x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",
                                  x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",
                                  x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",
                                  x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",
                                  x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",
                                  x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",
                                  x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",
                                  x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",
                                  x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",
                                  x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",
    
                                  x"0",x"0",x"0",x"0",x"0",x"3",x"3",x"0",x"0",x"3",x"3",x"0",x"0",x"0",x"0",x"0",  -- space ship
                                  x"0",x"0",x"0",x"3",x"3",x"4",x"4",x"0",x"0",x"4",x"4",x"3",x"3",x"0",x"0",x"0",
                                  x"0",x"0",x"3",x"4",x"4",x"4",x"4",x"4",x"4",x"4",x"4",x"4",x"4",x"3",x"0",x"0",
                                  x"0",x"3",x"4",x"4",x"4",x"4",x"4",x"4",x"4",x"4",x"4",x"4",x"4",x"4",x"3",x"0",
                                  x"0",x"3",x"4",x"4",x"4",x"4",x"4",x"5",x"5",x"4",x"4",x"4",x"4",x"4",x"3",x"0",
                                  x"3",x"4",x"4",x"4",x"4",x"4",x"5",x"6",x"6",x"5",x"4",x"4",x"4",x"4",x"4",x"3",
                                  x"3",x"4",x"4",x"4",x"4",x"5",x"6",x"6",x"5",x"5",x"5",x"4",x"4",x"4",x"4",x"3",
                                  x"0",x"0",x"4",x"4",x"5",x"5",x"5",x"5",x"5",x"5",x"5",x"5",x"4",x"4",x"0",x"0",
                                  x"0",x"0",x"4",x"4",x"5",x"5",x"5",x"5",x"5",x"5",x"5",x"5",x"4",x"4",x"0",x"0",
                                  x"3",x"4",x"4",x"4",x"4",x"5",x"5",x"5",x"5",x"5",x"5",x"4",x"4",x"4",x"4",x"3",
                                  x"3",x"4",x"4",x"4",x"4",x"4",x"5",x"5",x"5",x"5",x"4",x"4",x"4",x"4",x"4",x"3",
                                  x"0",x"3",x"4",x"4",x"4",x"4",x"4",x"5",x"5",x"4",x"4",x"4",x"4",x"4",x"3",x"0",
                                  x"0",x"3",x"4",x"4",x"4",x"4",x"4",x"4",x"4",x"4",x"4",x"4",x"4",x"4",x"3",x"0",
                                  x"0",x"0",x"3",x"4",x"4",x"4",x"4",x"4",x"4",x"4",x"4",x"4",x"4",x"3",x"0",x"0",
                                  x"0",x"0",x"0",x"3",x"3",x"4",x"4",x"0",x"0",x"4",x"4",x"3",x"3",x"0",x"0",x"0",
                                  x"0",x"0",x"0",x"0",x"0",x"3",x"3",x"0",x"0",x"3",x"3",x"0",x"0",x"0",x"0",x"0",

                                  x"0",x"0",x"0",x"0",x"0",x"4",x"4",x"4",x"4",x"4",x"0",x"0",x"0",x"0",x"0",x"0",  -- asteroid -big
                                  x"0",x"0",x"0",x"0",x"0",x"4",x"4",x"3",x"3",x"4",x"4",x"4",x"0",x"0",x"0",x"0",
                                  x"0",x"0",x"0",x"0",x"4",x"4",x"4",x"3",x"3",x"3",x"4",x"4",x"4",x"4",x"0",x"0",
                                  x"0",x"0",x"0",x"0",x"4",x"4",x"3",x"3",x"3",x"4",x"4",x"4",x"4",x"4",x"4",x"0",
                                  x"0",x"0",x"0",x"4",x"3",x"3",x"3",x"2",x"3",x"4",x"3",x"3",x"3",x"3",x"4",x"2",
                                  x"0",x"0",x"4",x"4",x"3",x"2",x"1",x"2",x"3",x"4",x"3",x"2",x"2",x"3",x"3",x"2",
                                  x"0",x"4",x"4",x"2",x"2",x"1",x"2",x"2",x"3",x"4",x"4",x"2",x"2",x"2",x"2",x"2",
                                  x"3",x"3",x"3",x"2",x"1",x"2",x"2",x"2",x"2",x"2",x"4",x"2",x"1",x"2",x"2",x"2",
                                  x"3",x"3",x"2",x"2",x"1",x"1",x"2",x"2",x"2",x"3",x"4",x"2",x"1",x"2",x"1",x"1",
                                  x"1",x"2",x"2",x"1",x"1",x"2",x"2",x"2",x"3",x"3",x"4",x"1",x"2",x"2",x"1",x"0",
                                  x"1",x"1",x"2",x"1",x"3",x"3",x"4",x"3",x"3",x"4",x"2",x"1",x"2",x"1",x"1",x"0",
                                  x"0",x"1",x"1",x"1",x"2",x"2",x"2",x"3",x"3",x"3",x"2",x"1",x"1",x"1",x"1",x"0",
                                  x"0",x"0",x"1",x"1",x"1",x"2",x"2",x"2",x"3",x"3",x"1",x"1",x"1",x"1",x"0",x"0",
                                  x"0",x"0",x"0",x"1",x"1",x"1",x"1",x"2",x"3",x"2",x"2",x"1",x"1",x"0",x"0",x"0",
                                  x"0",x"0",x"0",x"0",x"0",x"1",x"1",x"1",x"1",x"1",x"1",x"1",x"0",x"0",x"0",x"0",
                                  x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"1",x"1",x"1",x"0",x"0",x"0",x"0",x"0",x"0",

                                  x"0",x"0",x"0",x"0",x"4",x"4",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",  -- asteroid -medium
                                  x"0",x"0",x"4",x"4",x"4",x"2",x"2",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",
                                  x"0",x"3",x"4",x"3",x"3",x"3",x"2",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",
                                  x"3",x"3",x"3",x"3",x"3",x"2",x"2",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",
                                  x"3",x"2",x"2",x"2",x"3",x"2",x"1",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",
                                  x"0",x"2",x"2",x"2",x"2",x"2",x"1",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",
                                  x"0",x"0",x"1",x"1",x"2",x"1",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",
                                  x"0",x"0",x"0",x"1",x"1",x"1",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",
                                  x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",
                                  x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",
                                  x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",
                                  x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",
                                  x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",
                                  x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",
                                  x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",
                                  x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",
                                  
                                  x"0",x"4",x"4",x"3",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",  -- asteroid -small
                                  x"3",x"3",x"3",x"2",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",
                                  x"2",x"3",x"2",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",
                                  x"0",x"1",x"1",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",
                                  x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",
                                  x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",
                                  x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",
                                  x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",
                                  x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",
                                  x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",
                                  x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",
                                  x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",
                                  x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",
                                  x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",
                                  x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",
                                  x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",
    
                                  x"6",x"5",x"0",x"0",x"0",x"2",x"2",x"2",x"2",x"2",x"2",x"0",x"0",x"0",x"0",x"0", -- circle gray
                                  x"0",x"0",x"0",x"2",x"2",x"0",x"0",x"0",x"0",x"0",x"0",x"2",x"2",x"0",x"0",x"0",
                                  x"0",x"0",x"2",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"2",x"0",x"0",
                                  x"0",x"2",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"2",x"0",
                                  x"0",x"2",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"2",x"0",
                                  x"2",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"2",
                                  x"2",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"2",
                                  x"2",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"2",
                                  x"2",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"2",
                                  x"2",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"2",
                                  x"2",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"2",
                                  x"0",x"2",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"2",x"0",
                                  x"0",x"2",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"2",x"0",
                                  x"0",x"0",x"2",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"2",x"0",x"0",
                                  x"0",x"0",x"0",x"2",x"2",x"0",x"0",x"0",x"0",x"0",x"0",x"2",x"2",x"0",x"0",x"0",
                                  x"0",x"0",x"0",x"0",x"0",x"2",x"2",x"2",x"2",x"2",x"2",x"0",x"0",x"0",x"0",x"0",
                                others => (others => '0'));
begin

  -- ***********************************
  -- *                                 *
  -- *  VGA_motor                      *
  -- *    main components              *
  -- *                                 *
  -- ***********************************

  -- Clock divisor
  -- Divide system clock (100 MHz) by 4
  process(clk)
  begin
    if rising_edge(clk) then
      if rst='1' then
	ClkDiv <= (others => '0');
      else
	ClkDiv <= ClkDiv + 1;
      end if;
    end if;
  end process;
	
  -- 25 MHz clock (one system clock pulse width)
  Clk25 <= '1' when (ClkDiv = 3) else '0';
		
  -- Horizontal pixel counter
  process(clk)
  begin
	if rising_edge(clk) then
	  if rst='1' then
		Xpixel <= (others => '0');
	  elsif Clk25 = '1' then
		if Xpixel = X"320" then -- = 800 decimal
			  Xpixel <= (others => '0');
		else
			Xpixel <= Xpixel + 1;
		end if;
	  end if;
	end if;
  end process;
  -- Horizontal sync
  Hsync <= '0' when (Xpixel > X"28F") and (Xpixel < X"2F1") else '1';
  
  -- Vertical pixel counter
  process(clk)
  begin
	if rising_edge(clk) then
	  if rst='1' then
		Ypixel <= (others => '0');
	  elsif Clk25 = '1' and Xpixel = X"320" then	
		if Ypixel = X"209" then -- = 521 decimal
			  Ypixel <= (others => '0');
		else
			Ypixel <= Ypixel + 1;
		end if;
	  end if;
	end if;
  end process;
  -- Vertical sync  
  Vsync <= '0' when (Ypixel > X"1E9") and (Ypixel < X"1ED") else '1';
  
  -- Video blanking signal
  blank <= '0' when ((Xpixel < 640) and  (Ypixel < 480))
					   else '1'; 
  



  -- ***********************************
  -- *                                 *
  -- *  Tile mem                       *
  -- *    main components              *
  -- *                                 *
  -- ***********************************

  -- Tile memory
  process(clk)
  begin
    if rising_edge(clk) then
      if (blank = '0') then
        tilePixel <= tileMem(to_integer(tileAddr));
      else
        tilePixel <= (others => '0');
      end if;
    end if;
  end process;
	
  -- Tile memory address composite
  tileAddr <= unsigned(tileListData(4 downto 0)) & Ypixel(4 downto 2) & Xpixel(4 downto 2);     -- TODO combine and shorten these long lines

  -- Picture memory address composite
  tileListData <= tileList(to_integer(to_unsigned(20, 7) * Ypixel(8 downto 5) + Xpixel(9 downto 5)));





  -- ***********************************
  -- *                                 *
  -- *  Sprite mem                     *
  -- *    main components              *
  -- *                                 *
  -- ***********************************

  -- How spriteList is structured:
  -- Since we are using 8x8 big pixels we need to remove the last 3 bits from cordinates
  -- varibles startX, startY, endX, endY, sprite_type
  --> size 7 bit * 4 + (5 decimal = 3 bit) --> 31 bits

  -- spriteList(1)(30 downto 28) --> sprite_type
  -- spriteList(1)(27 downto 21) --> startX
  -- spriteList(1)(20 downto 14) --> startY
  -- spriteList(1)(13 downto 7 ) --> endX
  -- spriteList(1)(6 downto  0 ) --> endY

  -- change / read sprite mem
  process(clk)
  begin
    if rising_edge(clk) then
      if (spriteWrite = '1') then
        spriteList(to_integer(spriteListPos)) <= spriteType & spriteX & spriteY & (spriteX+"1111") & (spriteY+"1111");
      else
        spriteOut <= spriteList(to_integer(spriteListPos))(30 downto 14);
      end if;
    end if;
  end process;
  
  -- We are using 4 bit color (15 colors)
  sprite0pix <= spriteMem(to_integer( (255* to_integer(spriteList(0)(30 downto 28)))  + ((16*(Ypixel(9 downto 2) - spriteList(0)(20 downto 14))) + (Xpixel(9 downto 2) - spriteList(0)(27 downto 21) + spriteList(0)(30 downto 28)))  )) 
                  when   
                 Xpixel(9 downto 2) >= spriteList(0)(27 downto 21) and 
                 Xpixel(9 downto 2) <= spriteList(0)(13 downto 7 ) and
                 Ypixel(9 downto 2) >= spriteList(0)(20 downto 14) and 
                 Ypixel(9 downto 2) <= spriteList(0)(6  downto 0 ) 
                 else "0000" ;

  sprite1pix <= spriteMem(to_integer( (255* to_integer(spriteList(1)(30 downto 28)))  + ((16*(Ypixel(9 downto 2) - spriteList(1)(20 downto 14))) + (Xpixel(9 downto 2) - spriteList(1)(27 downto 21) + spriteList(1)(30 downto 28)))  )) 
               when   
                Xpixel(9 downto 2) >= spriteList(1)(27 downto 21) and 
                Xpixel(9 downto 2) <= spriteList(1)(13 downto 7 ) and
                Ypixel(9 downto 2) >= spriteList(1)(20 downto 14) and 
                Ypixel(9 downto 2) <= spriteList(1)(6  downto 0 ) 
                else "0000" ;

  sprite2pix <= spriteMem(to_integer( (255* to_integer(spriteList(2)(30 downto 28)))  + ((16*(Ypixel(9 downto 2) - spriteList(2)(20 downto 14))) + (Xpixel(9 downto 2) - spriteList(2)(27 downto 21) + spriteList(2)(30 downto 28)))  )) 
                when   
                 Xpixel(9 downto 2) >= spriteList(2)(27 downto 21) and 
                 Xpixel(9 downto 2) <= spriteList(2)(13 downto 7 ) and
                 Ypixel(9 downto 2) >= spriteList(2)(20 downto 14) and 
                 Ypixel(9 downto 2) <= spriteList(2)(6  downto 0 ) 
                 else "0000" ;

  sprite3pix <= spriteMem(to_integer( (255* to_integer(spriteList(3)(30 downto 28)))  + ((16*(Ypixel(9 downto 2) - spriteList(3)(20 downto 14))) + (Xpixel(9 downto 2) - spriteList(3)(27 downto 21) + spriteList(3)(30 downto 28)))  )) 
                 when   
                  Xpixel(9 downto 2) >= spriteList(3)(27 downto 21) and 
                  Xpixel(9 downto 2) <= spriteList(3)(13 downto 7 ) and
                  Ypixel(9 downto 2) >= spriteList(3)(20 downto 14) and 
                  Ypixel(9 downto 2) <= spriteList(3)(6  downto 0 ) 
                  else "0000" ;


  -- Changing the formating of the code. this is because i can change all the sprite list numbers att the same time. It is the same code as the blocks above
  sprite4pix <= spriteMem(to_integer( (255* to_integer(spriteList(4)(30 downto 28)))  + 
                            ((16*(Ypixel(9 downto 2) - spriteList(4)(20 downto 14))) + 
                                 (Xpixel(9 downto 2) - spriteList(4)(27 downto 21) + 
                                                       spriteList(4)(30 downto 28)))  ))  when   
                                 Xpixel(9 downto 2) >= spriteList(4)(27 downto 21) and 
                                 Xpixel(9 downto 2) <= spriteList(4)(13 downto 7 ) and
                                 Ypixel(9 downto 2) >= spriteList(4)(20 downto 14) and 
                                 Ypixel(9 downto 2) <= spriteList(4)(6  downto 0 ) else "0000" ;
  
  sprite5pix <= spriteMem(to_integer( (255* to_integer(spriteList(5)(30 downto 28)))  + 
                            ((16*(Ypixel(9 downto 2) - spriteList(5)(20 downto 14))) + 
                                 (Xpixel(9 downto 2) - spriteList(5)(27 downto 21) + 
                                                       spriteList(5)(30 downto 28)))  ))  when   
                                 Xpixel(9 downto 2) >= spriteList(5)(27 downto 21) and 
                                 Xpixel(9 downto 2) <= spriteList(5)(13 downto 7 ) and
                                 Ypixel(9 downto 2) >= spriteList(5)(20 downto 14) and 
                                 Ypixel(9 downto 2) <= spriteList(5)(6  downto 0 ) else "0000" ;
 
  sprite6pix <= spriteMem(to_integer( (255* to_integer(spriteList(6)(30 downto 28)))  + 
                            ((16*(Ypixel(9 downto 2) - spriteList(6)(20 downto 14))) + 
                                 (Xpixel(9 downto 2) - spriteList(6)(27 downto 21) + 
                                                       spriteList(6)(30 downto 28)))  ))  when   
                                 Xpixel(9 downto 2) >= spriteList(6)(27 downto 21) and 
                                 Xpixel(9 downto 2) <= spriteList(6)(13 downto 7 ) and
                                 Ypixel(9 downto 2) >= spriteList(6)(20 downto 14) and 
                                 Ypixel(9 downto 2) <= spriteList(6)(6  downto 0 ) else "0000" ;

  sprite7pix <= spriteMem(to_integer( (255* to_integer(spriteList(7)(30 downto 28)))  + 
                            ((16*(Ypixel(9 downto 2) - spriteList(7)(20 downto 14))) + 
                                 (Xpixel(9 downto 2) - spriteList(7)(27 downto 21) + 
                                                       spriteList(7)(30 downto 28)))  ))  when   
                                 Xpixel(9 downto 2) >= spriteList(7)(27 downto 21) and 
                                 Xpixel(9 downto 2) <= spriteList(7)(13 downto 7 ) and
                                 Ypixel(9 downto 2) >= spriteList(7)(20 downto 14) and 
                                 Ypixel(9 downto 2) <= spriteList(7)(6  downto 0 ) else "0000" ;
       
  sprite8pix <= spriteMem(to_integer( (255* to_integer(spriteList(8)(30 downto 28)))  + 
                            ((16*(Ypixel(9 downto 2) - spriteList(8)(20 downto 14))) + 
                                 (Xpixel(9 downto 2) - spriteList(8)(27 downto 21) + 
                                                       spriteList(8)(30 downto 28)))  ))  when   
                                 Xpixel(9 downto 2) >= spriteList(8)(27 downto 21) and 
                                 Xpixel(9 downto 2) <= spriteList(8)(13 downto 7 ) and
                                 Ypixel(9 downto 2) >= spriteList(8)(20 downto 14) and 
                                 Ypixel(9 downto 2) <= spriteList(8)(6  downto 0 ) else "0000" ;
      
  sprite9pix <= spriteMem(to_integer( (255* to_integer(spriteList(9)(30 downto 28)))  + 
                            ((16*(Ypixel(9 downto 2) - spriteList(9)(20 downto 14))) + 
                                 (Xpixel(9 downto 2) - spriteList(9)(27 downto 21) + 
                                                       spriteList(9)(30 downto 28)))  ))  when   
                                 Xpixel(9 downto 2) >= spriteList(9)(27 downto 21) and 
                                 Xpixel(9 downto 2) <= spriteList(9)(13 downto 7 ) and
                                 Ypixel(9 downto 2) >= spriteList(9)(20 downto 14) and 
                                 Ypixel(9 downto 2) <= spriteList(9)(6  downto 0 ) else "0000" ;

  sprite10pix<= spriteMem(to_integer( (255* to_integer(spriteList(10)(30 downto 28)))  + 
                            ((16*(Ypixel(9 downto 2) - spriteList(10)(20 downto 14))) + 
                                 (Xpixel(9 downto 2) - spriteList(10)(27 downto 21) + 
                                                       spriteList(10)(30 downto 28)))  ))  when   
                                 Xpixel(9 downto 2) >= spriteList(10)(27 downto 21) and 
                                 Xpixel(9 downto 2) <= spriteList(10)(13 downto 7 ) and
                                 Ypixel(9 downto 2) >= spriteList(10)(20 downto 14) and 
                                 Ypixel(9 downto 2) <= spriteList(10)(6  downto 0 ) else "0000" ;
  
  sprite11pix<= spriteMem(to_integer( (255* to_integer(spriteList(11)(30 downto 28)))  + 
                            ((16*(Ypixel(9 downto 2) - spriteList(11)(20 downto 14))) + 
                                 (Xpixel(9 downto 2) - spriteList(11)(27 downto 21) + 
                                                       spriteList(11)(30 downto 28)))  ))  when   
                                 Xpixel(9 downto 2) >= spriteList(11)(27 downto 21) and 
                                 Xpixel(9 downto 2) <= spriteList(11)(13 downto 7 ) and
                                 Ypixel(9 downto 2) >= spriteList(11)(20 downto 14) and 
                                 Ypixel(9 downto 2) <= spriteList(11)(6  downto 0 ) else "0000" ;
 
  sprite12pix<= spriteMem(to_integer( (255* to_integer(spriteList(12)(30 downto 28)))  + 
                            ((16*(Ypixel(9 downto 2) - spriteList(12)(20 downto 14))) + 
                                 (Xpixel(9 downto 2) - spriteList(12)(27 downto 21) + 
                                                       spriteList(12)(30 downto 28)))  ))  when   
                                 Xpixel(9 downto 2) >= spriteList(12)(27 downto 21) and 
                                 Xpixel(9 downto 2) <= spriteList(12)(13 downto 7 ) and
                                 Ypixel(9 downto 2) >= spriteList(12)(20 downto 14) and 
                                 Ypixel(9 downto 2) <= spriteList(12)(6  downto 0 ) else "0000" ;

  sprite13pix<= spriteMem(to_integer( (255* to_integer(spriteList(13)(30 downto 28)))  + 
                            ((16*(Ypixel(9 downto 2) - spriteList(13)(20 downto 14))) + 
                                 (Xpixel(9 downto 2) - spriteList(13)(27 downto 21) + 
                                                       spriteList(13)(30 downto 28)))  ))  when   
                                 Xpixel(9 downto 2) >= spriteList(13)(27 downto 21) and 
                                 Xpixel(9 downto 2) <= spriteList(13)(13 downto 7 ) and
                                 Ypixel(9 downto 2) >= spriteList(13)(20 downto 14) and 
                                 Ypixel(9 downto 2) <= spriteList(13)(6  downto 0 ) else "0000" ;
       
  sprite14pix<= spriteMem(to_integer( (255* to_integer(spriteList(14)(30 downto 28)))  + 
                            ((16*(Ypixel(9 downto 2) - spriteList(14)(20 downto 14))) + 
                                 (Xpixel(9 downto 2) - spriteList(14)(27 downto 21) + 
                                                       spriteList(14)(30 downto 28)))  ))  when   
                                 Xpixel(9 downto 2) >= spriteList(14)(27 downto 21) and 
                                 Xpixel(9 downto 2) <= spriteList(14)(13 downto 7 ) and
                                 Ypixel(9 downto 2) >= spriteList(14)(20 downto 14) and 
                                 Ypixel(9 downto 2) <= spriteList(14)(6  downto 0 ) else "0000" ;
      
  sprite15pix<= spriteMem(to_integer( (255* to_integer(spriteList(15)(30 downto 28)))  + 
                            ((16*(Ypixel(9 downto 2) - spriteList(15)(20 downto 14))) + 
                                 (Xpixel(9 downto 2) - spriteList(15)(27 downto 21) + 
                                                       spriteList(15)(30 downto 28)))  ))  when   
                                 Xpixel(9 downto 2) >= spriteList(15)(27 downto 21) and 
                                 Xpixel(9 downto 2) <= spriteList(15)(13 downto 7 ) and
                                 Ypixel(9 downto 2) >= spriteList(15)(20 downto 14) and 
                                 Ypixel(9 downto 2) <= spriteList(15)(6  downto 0 ) else "0000" ;


  -- Pixel chooser
  outputPixel_4bit <= sprite0pix  when sprite0pix /= 0 else
                      sprite1pix  when sprite1pix /= 0 else
                      sprite2pix  when sprite2pix /= 0 else
                      sprite3pix  when sprite3pix /= 0 else
                      sprite4pix  when sprite0pix /= 0 else
                      sprite5pix  when sprite1pix /= 0 else
                      sprite6pix  when sprite2pix /= 0 else
                      sprite7pix  when sprite3pix /= 0 else
                      sprite8pix  when sprite0pix /= 0 else
                      sprite9pix  when sprite1pix /= 0 else
                      sprite10pix when sprite2pix /= 0 else
                      sprite11pix when sprite3pix /= 0 else
                      sprite12pix when sprite0pix /= 0 else
                      sprite13pix when sprite1pix /= 0 else
                      sprite14pix when sprite2pix /= 0 else
                      sprite15pix when sprite3pix /= 0 else
                      tilePixel;

  --pixel decoder
  outputPixel <= "00000000" when outputPixel_4bit = 0  else     -- black/ transparent
                 "01001001" when outputPixel_4bit = 1  else     -- gray-dark
                 "01001001" when outputPixel_4bit = 2  else     -- gray-medium-dark
                 "01101101" when outputPixel_4bit = 3  else     -- gray-medium-light
                 "10110110" when outputPixel_4bit = 4  else     -- gray-light
                 "00000010" when outputPixel_4bit = 5  else     -- neon-blue
                 "00000011" when outputPixel_4bit = 6  else     -- neon-blue-light
                 "11111111" when outputPixel_4bit = 7  else     -- white
                 "00000000" when outputPixel_4bit = 8  else
                 "00000000" when outputPixel_4bit = 9  else
                 "00000000" when outputPixel_4bit = 10 else
                 "00000000" when outputPixel_4bit = 11 else
                 "00000000" when outputPixel_4bit = 12 else
                 "00000000" when outputPixel_4bit = 13 else
                 "00000000" when outputPixel_4bit = 14 else
                 "00000000";
 

  -- VGA generation
  vgaRed(2) 	<=   outputPixel(7);
  vgaRed(1) 	<=   outputPixel(6);
  vgaRed(0) 	<=   outputPixel(5);
  vgaGreen(2) <=   outputPixel(4);
  vgaGreen(1) <=   outputPixel(3);
  vgaGreen(0) <=   outputPixel(2);
  vgaBlue(2) 	<=   outputPixel(1);
  vgaBlue(1) 	<=   outputPixel(0);


end Behavioral;

