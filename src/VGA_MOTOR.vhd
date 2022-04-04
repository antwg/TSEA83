--------------------------------------------------------------------------------
-- VGA MOTOR
-- Anders Nilsson
-- 16-feb-2016
-- Version 1.1


-- library declaration
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;            -- basic IEEE library
use IEEE.NUMERIC_STD.ALL;               -- IEEE library for the unsigned type


-- entity
entity VGA_MOTOR is
  port ( clk			: in std_logic;
	data			      : in std_logic_vector(7 downto 0);
	addr		      	: out unsigned(10 downto 0);
	rst		        	: in std_logic;
	vgaRed		      : out std_logic_vector(2 downto 0);
	vgaGreen	      : out std_logic_vector(2 downto 0);
	vgaBlue		      : out std_logic_vector(2 downto 1);
	Hsync		        : out std_logic;
	Vsync		        : out std_logic);
end VGA_MOTOR;


-- architecture
architecture Behavioral of VGA_MOTOR is

    signal	Xpixel	        : unsigned(9 downto 0);         -- Horizontal pixel counter
    signal	Ypixel	        : unsigned(9 downto 0);		-- Vertical pixel counter
    signal	ClkDiv	        : unsigned(1 downto 0);		-- Clock divisor, to generate 25 MHz signal
    signal	Clk25		        : std_logic;			-- One pulse width 25 MHz signal
		
    signal 	tilePixel       : unsigned(3 downto 0);	-- Tile pixel data
    signal 	outputPixel_4bit       : unsigned(3 downto 0);
    signal 	outputPixel     : std_logic_vector(7 downto 0);		
    signal	tileAddr	      : unsigned(10 downto 0);	-- Tile address

    signal        blank     : std_logic;                    -- blanking signal
    signal tileListData     : unsigned(7 downto 0);
    signal sprite1          : std_logic;   

    signal sprite1pix       : unsigned(3 downto 0); 
    signal sprite2pix       : unsigned(3 downto 0); 
	

    -- creating tile mem
    type ram_1 is array (0 to 2047) of unsigned(7 downto 0);
    signal tileList : ram_1 := (others => (others => '0'));
    type ram_2 is array (0 to 2047) of unsigned(3 downto 0);
    signal tileMem : ram_2 := (others => (others => '0'));

    -- creates the sprite memory
    type ram_3 is array (0 to 32) of unsigned(43 downto 0);
    signal spriteList : ram_3 := (others => (others => '0'));
    type ram_4 is array (0 to 2047) of unsigned(3 downto 0); -- Every sprite is 8x8 an there are 32 sprite -> 8x8x32=2048
    signal spriteMem : ram_4 := (others => (others => '0'));
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

  -- how to structure sprite mem:
  -- Since we are using 8x8 big pixels we only need to remove the last 3 bits from cordinates
  -- varibles startX, startY, endX, endY, sprite_type
  --> size 6 bit * 4 + (5= 3 bit) --> 27 bits

  -- spriteList(1)(26 downto 24) --> sprite_type
  -- spriteList(1)(23 downto 18) --> startX
  -- spriteList(1)(17 downto 12) --> startY
  -- spriteList(1)(11 downto 6 ) --> endX
  -- spriteList(1)(5 downto  0 ) --> endY

  -- We are using 4 bit color (15 colors)
 sprite1pix <= spriteMem(to_integer(8* spriteList(1)(26 downto 24)    +
             ((8*(Ypixel(9 downto 4) - spriteList(1)(17 downto 12)))  +   
                 (Xpixel(9 downto 4) - spriteList(1)(23 downto 18)))  )) when   
                 Xpixel(9 downto 4) >= spriteList(1)(23 downto 18) and 
                 Xpixel(9 downto 4) <= spriteList(1)(11 downto 6 ) and
                 Ypixel(9 downto 4) >= spriteList(1)(17 downto 12) and 
                 Ypixel(9 downto 4) <= spriteList(1)(5  downto 0 );

 sprite2pix <= spriteMem(to_integer(8* spriteList(2)(26 downto 24)    +
             ((8*(Ypixel(9 downto 4) - spriteList(2)(17 downto 12)))  +   
                 (Xpixel(9 downto 4) - spriteList(2)(23 downto 18)))  )) when   
                 Xpixel(9 downto 4) >= spriteList(2)(23 downto 18) and 
                 Xpixel(9 downto 4) <= spriteList(2)(11 downto 6 ) and
                 Ypixel(9 downto 4) >= spriteList(2)(17 downto 12) and 
                 Ypixel(9 downto 4) <= spriteList(2)(5  downto 0 );

  -- Pixel chooser
  outputPixel_4bit <= sprite1pix when sprite1pix /= 0 else
                 sprite2pix when sprite2pix /= 0 else
                 tilePixel;

  --pixel decoder
  outputPixel <= "00000000" when outputPixel_4bit = 0  else
                 "00000000" when outputPixel_4bit = 1  else
                 "00000000" when outputPixel_4bit = 2  else
                 "00000000" when outputPixel_4bit = 3  else
                 "00000000" when outputPixel_4bit = 4  else
                 "00000000" when outputPixel_4bit = 5  else
                 "00000000" when outputPixel_4bit = 6  else
                 "00000000" when outputPixel_4bit = 7  else
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

