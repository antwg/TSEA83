-- VGA MOTOR   

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
  spriteData      : in unsigned(15 downto 0);
  spriteListPos   : in  unsigned(4 downto 0); -- where in the "spriteList" the sprite is stored
  spriteOut       : out unsigned(15 downto 0)
  );
  

end VGA_MOTOR;


-- architecture
architecture Behavioral of VGA_MOTOR is

    signal spriteX         :  unsigned(7 downto 0);        -- cordinates for sprite. Note: the sprite cord is divided by 8	
    signal spriteY         :  unsigned(7 downto 0);	

    signal	Xpixel	        : unsigned(9 downto 0);        -- Horizontal pixel counter
    signal	Ypixel	        : unsigned(9 downto 0);		     -- Vertical pixel counter
    --signal	ClkDiv	        : unsigned(1 downto 0);		   -- Clock divisor, to generate 25 MHz signal
    signal	ClkDiv	        : unsigned(0 downto 0);            	   -- Clock divisor, to generate 25 MHz signal
    signal	Clk25		        : std_logic;		               -- One pulse width 25 MHz signal
		
    signal 	tilePixel       : unsigned(3 downto 0);	       -- Tile pixel data
    signal 	outputPixel_4bit : unsigned(3 downto 0);
    signal 	outputPixel     : std_logic_vector(7 downto 0);		
    signal	tileAddr	      : unsigned(10 downto 0);	     -- Tile address (temporary varible)
    signal  collision       : std_logic := '0';

    signal blank            : std_logic;                   -- blanking signal
    signal tileListData     : unsigned(7 downto 0);

    signal Xoffset          : unsigned(3 downto 0);
    signal Yoffset          : unsigned(3 downto 0);
 
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
    signal tileMem : ram_2 := ( --x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",   -- Void (black)   
                                --x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",
                                --x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",
                                --x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",
                                --x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",
                                --x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",
                                --x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",
                                --x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",
                                x"1",x"0",x"1",x"0",x"1",x"0",x"1",x"0",   -- Debug tile 
                                x"0",x"1",x"0",x"1",x"0",x"1",x"0",x"1",
                                x"1",x"0",x"1",x"0",x"1",x"0",x"1",x"0",
                                x"0",x"1",x"0",x"1",x"0",x"1",x"0",x"1",
                                x"1",x"0",x"1",x"0",x"1",x"0",x"1",x"0",
                                x"0",x"1",x"0",x"1",x"0",x"1",x"0",x"1",
                                x"1",x"0",x"1",x"0",x"1",x"0",x"1",x"0",
                                x"0",x"1",x"0",x"1",x"0",x"1",x"0",x"1",
    
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


    type ram_5 is array (0 to 31) of unsigned(3 downto 0);
    signal offsetList : ram_5 := (others => (others => '0'));


    type ram_3 is array (0 to 31) of unsigned(15 downto 0);
    signal spriteList : ram_3 := (others => (others => '0'));

    -- 0 black/ transparent
    -- 1 gray-dark
    -- 2 gray-medium-dark
    -- 3 gray-medium-light
    -- 4 gray-light
    -- 5 neon-blue
    -- 6 neon-blue-light
    -- 7 white

    type ram_4 is array (0 to 2047) of unsigned(3 downto 0); -- Every sprite is 16x16 an there are 8 sprite -> 16x16x8=2048
    signal spriteMem : ram_4 := ( x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",   -- Void (black)   
                                x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",
                                x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",
                                x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",
                                x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",
                                x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",
                                x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",
                                x"0",x"0",x"0",x"0",x"0",x"0",x"0",x"0",

                                x"0",x"0",x"0",x"1",x"1",x"0",x"0",x"0",   -- Space ship 
                                x"0",x"0",x"1",x"3",x"3",x"1",x"0",x"0",
                                x"0",x"1",x"3",x"3",x"3",x"3",x"1",x"0",
                                x"1",x"3",x"3",x"6",x"6",x"3",x"3",x"1",
                                x"1",x"3",x"3",x"6",x"6",x"3",x"3",x"1",
                                x"0",x"1",x"3",x"3",x"3",x"3",x"1",x"0",
                                x"0",x"0",x"1",x"3",x"3",x"1",x"0",x"0",
                                x"0",x"0",x"0",x"1",x"1",x"0",x"0",x"0",

                                x"0",x"0",x"0",x"1",x"1",x"0",x"0",x"0",   -- Asteroid Dark
                                x"0",x"0",x"1",x"1",x"1",x"1",x"0",x"0",
                                x"0",x"1",x"1",x"1",x"1",x"1",x"1",x"0",
                                x"1",x"1",x"1",x"1",x"1",x"1",x"1",x"1",
                                x"1",x"1",x"1",x"1",x"1",x"1",x"1",x"1",
                                x"0",x"1",x"1",x"1",x"1",x"1",x"1",x"0",
                                x"0",x"0",x"1",x"1",x"1",x"1",x"0",x"0",
                                x"0",x"0",x"0",x"1",x"1",x"0",x"0",x"0",

                                x"0",x"0",x"0",x"3",x"3",x"0",x"0",x"0",   -- Asteroid Medium
                                x"0",x"0",x"3",x"3",x"3",x"3",x"0",x"0",
                                x"0",x"3",x"3",x"3",x"3",x"3",x"3",x"0",
                                x"3",x"3",x"3",x"3",x"3",x"3",x"3",x"3",
                                x"3",x"3",x"3",x"3",x"3",x"3",x"3",x"3",
                                x"0",x"3",x"3",x"3",x"3",x"3",x"3",x"0",
                                x"0",x"0",x"3",x"3",x"3",x"3",x"0",x"0",
                                x"0",x"0",x"0",x"3",x"3",x"0",x"0",x"0",

                                x"0",x"0",x"0",x"4",x"4",x"0",x"0",x"0",   -- Asteroid Light
                                x"0",x"0",x"4",x"4",x"4",x"4",x"0",x"0",
                                x"0",x"4",x"4",x"4",x"4",x"4",x"4",x"0",
                                x"4",x"4",x"4",x"4",x"4",x"4",x"4",x"4",
                                x"4",x"4",x"4",x"4",x"4",x"4",x"4",x"4",
                                x"0",x"4",x"4",x"4",x"4",x"4",x"4",x"0",
                                x"0",x"0",x"4",x"4",x"4",x"4",x"0",x"0",
                                x"0",x"0",x"0",x"4",x"4",x"0",x"0",x"0",


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
  Clk25 <= '1' when (ClkDiv = 1) else '0';
		
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
  tileAddr <= unsigned(tileListData(4 downto 0)) & Ypixel(4 downto 2) & Xpixel(4 downto 2);   

  -- Picture memory address composite
  tileListData <= tileList(to_integer(to_unsigned(20, 7) * Ypixel(8 downto 5) + Xpixel(9 downto 5)));




  -- ***********************************
  -- *                                 *
  -- *  Sprite mem                     *
  -- *    main components              *
  -- *                                 *
  -- ***********************************

  spriteOut <= spriteList(to_integer(spriteListPos));  
  process(clk)
  begin
    if rising_edge(clk) then

      if (collision = '1') then
        spriteList(31) <= x"1234";
      end if;
      

      if (spriteWrite = '1') then

        spriteList(to_integer(spriteListPos)) <= spriteData;

          if(   (spriteData(7 downto 0)- "111") > spriteData(7 downto 0) ) then
            offsetList(to_integer(spriteListPos)) <= spriteData(2 downto 0);
          else
            offsetList(to_integer(spriteListPos)) <= "111";
          end if;

      end if;
    end if;
  end process;


  sprite0pix <= spriteMem(to_integer( (64* to_integer(spriteList(1)(15 downto 13)))  + ((8*((Ypixel(9 downto 2)+7) - spriteList(1)(7 downto 0))) + ((Xpixel(9 downto 2)+7) - spriteList(0)(7 downto 0) ))  )) --18.69ns
                                  when   
                                Xpixel(9 downto 2) >= (spriteList(0)(7 downto 0)-offsetList(0)) and 
                                Xpixel(9 downto 2) <= (spriteList(0)(7 downto 0 )) and
                                Ypixel(9 downto 2) >= (spriteList(1)(7 downto 0)-offsetList(1)) and 
                                Ypixel(9 downto 2) <= (spriteList(1)(7 downto 0 ))
                                else "0000" ;


  sprite1pix <= spriteMem(to_integer( (64* to_integer(spriteList(3)(15 downto 13)))  + ((8*((Ypixel(9 downto 2)+7) - 
                                                      spriteList(3)(7 downto 0))) + ((Xpixel(9 downto 2)+7) - 
                                                      spriteList(2)(7 downto 0) ))  )) when   
                               Xpixel(9 downto 2) >= (spriteList(2)(7 downto 0)-offsetList(0)) and 
                               Xpixel(9 downto 2) <= (spriteList(2)(7 downto 0 )) and
                               Ypixel(9 downto 2) >= (spriteList(3)(7 downto 0)-offsetList(1)) and 
                               Ypixel(9 downto 2) <= (spriteList(3)(7 downto 0 ))
                               else "0000" ;      
                               
  sprite2pix <= spriteMem(to_integer( (64* to_integer(spriteList(5)(15 downto 13)))  + ((8*((Ypixel(9 downto 2)+7) - 
                                                      spriteList(5)(7 downto 0))) + ((Xpixel(9 downto 2)+7) - 
                                                      spriteList(4)(7 downto 0) ))  )) when   
                               Xpixel(9 downto 2) >= (spriteList(4)(7 downto 0)-offsetList(0)) and 
                               Xpixel(9 downto 2) <= (spriteList(4)(7 downto 0 )) and
                               Ypixel(9 downto 2) >= (spriteList(5)(7 downto 0)-offsetList(1)) and 
                               Ypixel(9 downto 2) <= (spriteList(5)(7 downto 0 ))
                               else "0000" ;  

  sprite3pix <= spriteMem(to_integer( (64* to_integer(spriteList(7)(15 downto 13)))  + ((8*((Ypixel(9 downto 2)+7) - 
                                                      spriteList(7)(7 downto 0))) + ((Xpixel(9 downto 2)+7) - 
                                                      spriteList(6)(7 downto 0) ))  )) when   
                               Xpixel(9 downto 2) >= (spriteList(6)(7 downto 0)-offsetList(0)) and 
                               Xpixel(9 downto 2) <= (spriteList(6)(7 downto 0 )) and
                               Ypixel(9 downto 2) >= (spriteList(7)(7 downto 0)-offsetList(1)) and 
                               Ypixel(9 downto 2) <= (spriteList(7)(7 downto 0 ))
                               else "0000" ;  

  sprite4pix <= spriteMem(to_integer( (64* to_integer(spriteList(9)(15 downto 13)))  + ((8*((Ypixel(9 downto 2)+7) - 
                                                      spriteList(9)(7 downto 0))) + ((Xpixel(9 downto 2)+7) - 
                                                      spriteList(8)(7 downto 0) ))  )) when   
                               Xpixel(9 downto 2) >= (spriteList(8)(7 downto 0)-offsetList(0)) and 
                               Xpixel(9 downto 2) <= (spriteList(8)(7 downto 0 )) and
                               Ypixel(9 downto 2) >= (spriteList(9)(7 downto 0)-offsetList(1)) and 
                               Ypixel(9 downto 2) <= (spriteList(9)(7 downto 0 ))
                               else "0000" ;  

  sprite5pix <= spriteMem(to_integer( (64* to_integer(spriteList(11)(15 downto 13)))  + ((8*((Ypixel(9 downto 2)+7) - 
                                                      spriteList(11)(7 downto 0))) + ((Xpixel(9 downto 2)+7) - 
                                                      spriteList(10)(7 downto 0) ))  )) when   
                               Xpixel(9 downto 2) >= (spriteList(10)(7 downto 0)-offsetList(0)) and 
                               Xpixel(9 downto 2) <= (spriteList(10)(7 downto 0 )) and
                               Ypixel(9 downto 2) >= (spriteList(11)(7 downto 0)-offsetList(1)) and 
                               Ypixel(9 downto 2) <= (spriteList(11)(7 downto 0 ))
                               else "0000" ;      
        
  sprite6pix <= spriteMem(to_integer( (64* to_integer(spriteList(13)(15 downto 13)))  + ((8*((Ypixel(9 downto 2)+7) - 
                                                      spriteList(13)(7 downto 0))) + ((Xpixel(9 downto 2)+7) - 
                                                      spriteList(12)(7 downto 0) ))  )) when   
                               Xpixel(9 downto 2) >= (spriteList(12)(7 downto 0)-offsetList(0)) and 
                               Xpixel(9 downto 2) <= (spriteList(12)(7 downto 0 )) and
                               Ypixel(9 downto 2) >= (spriteList(13)(7 downto 0)-offsetList(1)) and 
                               Ypixel(9 downto 2) <= (spriteList(13)(7 downto 0 ))
                               else "0000" ;  

  sprite7pix <= spriteMem(to_integer( (64* to_integer(spriteList(15)(15 downto 13)))  + ((8*((Ypixel(9 downto 2)+7) - 
                                                      spriteList(15)(7 downto 0))) + ((Xpixel(9 downto 2)+7) - 
                                                      spriteList(14)(7 downto 0) ))  )) when   
                               Xpixel(9 downto 2) >= (spriteList(14)(7 downto 0)-offsetList(0)) and 
                               Xpixel(9 downto 2) <= (spriteList(14)(7 downto 0 )) and
                               Ypixel(9 downto 2) >= (spriteList(15)(7 downto 0)-offsetList(1)) and 
                               Ypixel(9 downto 2) <= (spriteList(15)(7 downto 0 ))
                               else "0000" ;  

  sprite8pix <= spriteMem(to_integer( (64* to_integer(spriteList(17)(15 downto 13)))  + ((8*((Ypixel(9 downto 2)+7) - 
                                                      spriteList(17)(7 downto 0))) + ((Xpixel(9 downto 2)+7) - 
                                                      spriteList(16)(7 downto 0) ))  )) when   
                               Xpixel(9 downto 2) >= (spriteList(16)(7 downto 0)-offsetList(0)) and 
                               Xpixel(9 downto 2) <= (spriteList(16)(7 downto 0 )) and
                               Ypixel(9 downto 2) >= (spriteList(17)(7 downto 0)-offsetList(1)) and 
                               Ypixel(9 downto 2) <= (spriteList(17)(7 downto 0 ))
                               else "0000" ;  

  sprite9pix <= spriteMem(to_integer( (64* to_integer(spriteList(19)(15 downto 13)))  + ((8*((Ypixel(9 downto 2)+7) - 
                                                      spriteList(19)(7 downto 0))) + ((Xpixel(9 downto 2)+7) - 
                                                      spriteList(18)(7 downto 0) ))  )) when   
                               Xpixel(9 downto 2) >= (spriteList(18)(7 downto 0)-offsetList(0)) and 
                               Xpixel(9 downto 2) <= (spriteList(18)(7 downto 0 )) and
                               Ypixel(9 downto 2) >= (spriteList(19)(7 downto 0)-offsetList(1)) and 
                               Ypixel(9 downto 2) <= (spriteList(19)(7 downto 0 ))
                               else "0000" ;  


 
 -- collision detection
 -- when the sprite in the first postion in the list is colliding with another sprite.
 collision <= '1' when sprite0pix  /= 0 and
                      (sprite1pix  /= 0 or
                       sprite2pix  /= 0 or
                       sprite3pix  /= 0 or
                       sprite4pix  /= 0 or
                       sprite5pix  /= 0 or
                       sprite6pix  /= 0 or
                       sprite7pix  /= 0 or
                       sprite8pix  /= 0 or
                       sprite9pix  /= 0 or
                       sprite10pix /= 0 or
                       sprite11pix /= 0 or
                       sprite12pix /= 0 or
                       sprite13pix /= 0 or
                       sprite14pix /= 0 or
                       sprite15pix /= 0) else '0';


  -- Pixel chooser
  outputPixel_4bit <= sprite0pix  when sprite0pix /= 0 else
                      sprite1pix  when sprite1pix /= 0 else
                      sprite2pix  when sprite2pix /= 0 else
                      sprite3pix  when sprite3pix /= 0 else
                      sprite4pix  when sprite4pix /= 0 else
                      sprite5pix  when sprite5pix /= 0 else
                      sprite6pix  when sprite6pix /= 0 else
                      sprite7pix  when sprite7pix /= 0 else
                      sprite8pix  when sprite8pix /= 0 else
                      sprite9pix  when sprite9pix /= 0 else
                      sprite10pix when sprite10pix /= 0 else
                      sprite11pix when sprite11pix /= 0 else
                      sprite12pix when sprite12pix /= 0 else
                      sprite13pix when sprite13pix /= 0 else
                      sprite14pix when sprite14pix /= 0 else
                      sprite15pix when sprite15pix /= 0 else
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

