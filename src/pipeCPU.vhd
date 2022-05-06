library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity pipeCPU is
    generic (TCQ : in time := 100 ps);
	port (
        -- 50 MHZ clock stuff
        -- ========================
		CLK_IN1, RESET : in std_logic;
        -- ========================
        -- original clock stuff
        -- ========================
		--clk, rst : in std_logic;
        -- ========================
		UART_in : in std_logic;
		UART_out : out std_logic;
		--JA : in unsigned(15 downto 0);
		seg : out unsigned(7 downto 0);
		an : out unsigned(3 downto 0);
		vgaRed		    : out std_logic_vector(2 downto 0);
        vgaGreen	    : out std_logic_vector(2 downto 0);
        vgaBlue		    : out std_logic_vector(2 downto 1);
        Hsync		    : out std_logic;
        Vsync		    : out std_logic);


end pipeCPU;

architecture func of pipeCPU is

    ----------------------------- Internal signals --------------------------------
    signal IR1 : unsigned(31 downto 0) := (others => '0'); -- Fetch stage
    alias IR1_op : unsigned(7 downto 0) is IR1(31 downto 24);
    alias IR1_rd : unsigned(3 downto 0) is IR1(23 downto 20);
    alias IR1_ra : unsigned(3 downto 0) is IR1(19 downto 16);
    alias IR1_const : unsigned(15 downto 0) is IR1(15 downto 0);

    signal IR2 : unsigned(31 downto 0) := (others => '0'); -- Decode stage
    alias IR2_op : unsigned(7 downto 0) is IR2(31 downto 24);
    alias IR2_rd : unsigned(3 downto 0) is IR2(23 downto 20);
    alias IR2_ra : unsigned(3 downto 0) is IR2(19 downto 16);
    alias IR2_const : unsigned(15 downto 0) is IR2(15 downto 0);

    -- Stack pointer
    signal SP : unsigned(15 downto 0) := x"00FF";

    -- Status register
    signal status_reg_out : unsigned(3 downto 0) := (others => '0');
    alias ZF : std_logic is status_reg_out(0);
    alias NF : std_logic is status_reg_out(1);
    alias CF : std_logic is status_reg_out(2);
    alias VF : std_logic is status_reg_out(3);

    signal PC, PC1, JUMP_PC : unsigned(15 downto 0) := x"0001";

    signal PMdata_out : unsigned(31 downto 0) := (others => '0');
    signal pm_addr : unsigned(15 downto 0) := (others => '0');

    -- Data memory
    signal dm_addr : unsigned(15 downto 0) := (others => '0');
    signal dm_data_out : unsigned(15 downto 0) := (others => '0');
    signal dm_and_sm_data_out : unsigned(15 downto 0) := (others => '0');
    signal dm_we : std_logic := '0';

    -- Sprite memory/VGA
    signal sm_addr : unsigned(15 downto 0) := (others => '0');
    signal sm_we : std_logic := '0';
    signal spriteWrite      :  std_logic;            -- 1 -> writing   0 -> reading
    --signal spriteType       :  unsigned(2 downto 0); -- the order the sprite is locatet in "spriteMem"
    signal spriteListPos    :  unsigned(4 downto 0); -- where in the "spriteList" the sprite is stored
    --signal spriteX          :  unsigned(6 downto 0); -- cordinates for sprite. Note: the sprite cord is divided by 8	
    --signal spriteY          :  unsigned(5 downto 0);
    signal sm_data_out        :  unsigned(15 downto 0);


    -- ALU
    signal alu_out, alu_mux1, alu_mux2 : unsigned(15 downto 0):= (others => '0');
    -- Data bus
    signal data_bus : unsigned(15 downto 0) := (others => '0');
    signal new_status_reg : unsigned(3 downto 0) := (others => '0');

    -- Register file
    signal rf_we : std_logic := '0';
    signal rf_rd, rf_ra : unsigned(15 downto 0) := (others => '0');

    -- Loader signals
    signal boot_en : std_logic := '1';
    signal boot_done : std_logic := '0';
    signal boot_we : std_logic := '0';
    signal boot_addr : unsigned(15 downto 0) := (others => '0');
    signal boot_data_out : unsigned(31 downto 0) := (others => '0');
    signal boot_wait_cnt : unsigned(13 downto 0) := (others => '0');

    -- jumping
    signal jumping : std_logic := '0';

    -- UART com
    --signal com_send_byte : unsigned (7 downto 0) := (others => '0');
    --signal com_sent : std_logic := '0';
    --signal com_send : std_logic := '0';
    --signal com_debug_value : unsigned(7 downto 0) := (others => '1');
    --signal com_debug : std_logic := '1';
    --
    --signal com_pm_val : unsigned(31 downto 0) := (others => '0');
    --signal com_pm_part : unsigned(4 downto 0) := (others => '0');

    -- interrupts
    signal interrupt_en : std_logic := '1';
    signal interrupt : std_logic := '0';
    signal interrupt_handling : std_logic := '0';
    signal interrupt_handling_jump : std_logic := '0';

    -- Out to 7seg
    signal led_value : unsigned(15 downto 0) := (others => '0');
    signal led_addr : unsigned(3 downto 0) := "0000"; 
    signal led_null : unsigned(15 downto 0) := (others => '0');

    --joystick out 
    signal MISO : std_logic;
    signal SS : STD_LOGIC;								-- Slave Select, Pin 1, Port JA
    signal SCLK: STD_LOGIC;            							-- Serial Clock, Pin 4, Port JA
    signal MOSI : STD_LOGIC;							-- Master Out Slave In, Pin 2, Port JA

     

    -- Instructions
    constant NOP 		: unsigned(7 downto 0) := x"00";
    constant RJMP		: unsigned(7 downto 0) := x"01";
    constant BEQ		: unsigned(7 downto 0) := x"02";
    constant BNE 		: unsigned(7 downto 0) := x"03";
    constant BPL 		: unsigned(7 downto 0) := x"04";
    constant BMI 		: unsigned(7 downto 0) := x"05";
    constant BGE 		: unsigned(7 downto 0) := x"06";
    constant BLT 		: unsigned(7 downto 0) := x"07";
    constant LDI 		: unsigned(7 downto 0) := x"08";
    constant LD 		: unsigned(7 downto 0) := x"09";
    constant STI 		: unsigned(7 downto 0) := x"0A";
    constant ST  		: unsigned(7 downto 0) := x"0B";
    constant COPY		: unsigned(7 downto 0) := x"0C";
    constant ADD		: unsigned(7 downto 0) := x"0D";
    constant ADDI		: unsigned(7 downto 0) := x"0E";
    constant SUB		: unsigned(7 downto 0) := x"0F";
    constant SUBI		: unsigned(7 downto 0) := x"10";
    constant CMP		: unsigned(7 downto 0) := x"11";
    constant CMPI		: unsigned(7 downto 0) := x"12";
    constant I_AND		: unsigned(7 downto 0) := x"13";
    constant ANDI		: unsigned(7 downto 0) := x"14";
    constant I_OR		: unsigned(7 downto 0) := x"15";
    constant ORI		: unsigned(7 downto 0) := x"16";
    constant PUSH		: unsigned(7 downto 0) := x"17";
    constant POP		: unsigned(7 downto 0) := x"18";
    constant ADC		: unsigned(7 downto 0) := x"19";
    constant SBC 		: unsigned(7 downto 0) := x"1A";
    constant MUL 		: unsigned(7 downto 0) := x"1B";
    constant MULI 		: unsigned(7 downto 0) := x"1C";
    constant MULS		: unsigned(7 downto 0) := x"1D";
    constant MULSI		: unsigned(7 downto 0) := x"1E";
    constant LSLS		: unsigned(7 downto 0) := x"1F";
    constant LSLR		: unsigned(7 downto 0) := x"20";
    constant PUSR		: unsigned(7 downto 0) := x"21";
    constant POSR		: unsigned(7 downto 0) := x"22";
    constant SUBR		: unsigned(7 downto 0) := x"23";
    constant RET		: unsigned(7 downto 0) := x"24";
    constant PCR		: unsigned(7 downto 0) := x"25";


    ------------------------------------ Def components ---------------------------

    component PROG_MEM is
        port( clk : in std_logic;
              we : std_logic;
              addr : in unsigned(15 downto 0);
              data_out : out unsigned(31 downto 0);
              wr_addr : in unsigned(15 downto 0);
              wr_data : in unsigned(31 downto 0));
    end component;

    -- Sprite minne
    component VGA_MOTOR is
        port ( 
           clk	            : in std_logic;                         -- system clock
           rst              : in std_logic;   
           vgaRed		    : out std_logic_vector(2 downto 0);
           vgaGreen	        : out std_logic_vector(2 downto 0);
           vgaBlue		    : out std_logic_vector(2 downto 1);
           Hsync		    : out std_logic;
           Vsync		    : out std_logic;
           spriteWrite      : in  std_logic;            -- 1 -> writing   0 -> reading
           --spriteType       : in  unsigned(2 downto 0); -- the order the sprite is locatet in "spriteMem"
           spriteData       : in unsigned(15 downto 0);
           spriteListPos    : in  unsigned(4 downto 0); -- where in the "spriteList" the sprite is stored
           --spriteX          : in  unsigned(6 downto 0); -- cordinates for sprite. Note: the sprite cord is divided by 8	
           --spriteY          : in  unsigned(5 downto 0);
           spriteOut        : out unsigned(15 downto 0)
           
           );    -- VGA blue
    end component;


    component PROG_LOADER is
        port( clk, rst, rx, boot_en : in std_logic;
              done, we : out std_logic;
              addr : out unsigned(15 downto 0);
              data_out : out unsigned(31 downto 0));
    end component;

    --component UART_COM is
    --    port( clk, rst : in std_logic;
    --          bit_out : out std_logic;
    --          send_byte : in unsigned(7 downto 0);
    --          send : in std_logic;
    --          sent : out std_logic);
    --end component;

    component DATA_MEM is
        port( clk : in std_logic;
              we : in std_logic; -- write enable
              data_in : in unsigned(15 downto 0);
              addr : in unsigned(15 downto 0);
              data_out : out unsigned(15 downto 0));
              --led_addr : in unsigned(15 downto 0); 
              --led_out : out unsigned(15 downto 0));
    end component;

    component REG_FILE is
        port(
            rd_in : in unsigned(3 downto 0);
            ra_in : in unsigned(3 downto 0);
            we : in std_logic; -- write enable
            clk : in std_logic;
            data_in : in unsigned(15 downto 0);
            rd_out : out unsigned(15 downto 0);
            ra_out : out unsigned(15 downto 0);
            led_addr : in unsigned(3 downto 0); 
            led_out : out unsigned(15 downto 0));
    end component;

    component ALU is
        port ( MUX1: in unsigned(15 downto 0);
               MUX2 : in unsigned(15 downto 0);
               op_code : in unsigned(7 downto 0);
               result : out unsigned(15 downto 0);
               status_reg : out unsigned(3 downto 0);
               new_status_reg : in unsigned(3 downto 0);
               reset: in std_logic;
               clk : in std_logic);
    end component;

    component leddriver is
        Port ( clk,rst : in  STD_LOGIC;
               seg : out  UNSIGNED(7 downto 0);
               an : out  UNSIGNED (3 downto 0);
               value : in  UNSIGNED (15 downto 0));
    end component;

    -- 50 Mhz CLOCK STUFF
    -- =======================================
    component clk_wiz_v3_6 is
    port (
      CLK_IN1 : in std_logic;
      CLK_OUT1 : out std_logic;
      RESET : in std_logic;
      LOCKED : out std_logic);
    end component;

    signal locked_int : std_logic;  -- 1 when PLL has locked internal clock
    signal clk_int : std_logic;     -- internal clock
    signal rst_int : std_logic;     -- internal reset
    signal clk : std_logic;         -- clock for original design
    signal rst : std_logic;         -- reset for original design
    -- =======================================

begin

-------------------------------------- Components -------------------------------
  
   -- 50 Mhz CLOCK STUFF
   -- =======================================
   clknetwork : clk_wiz_v3_6
   port map (
         CLK_IN1 => CLK_IN1,
         CLK_OUT1 => clk_int,
         RESET => rst_int,
         LOCKED => locked_int);
   clk <= clk_int;
   rst <= (not locked_int or rst_int);
   -- =======================================

   prog_mem_comp : PROG_MEM port map(
		clk => clk,
		addr => pm_addr,
		data_out => PMdata_out,
		we => boot_we,
		wr_addr => boot_addr,
		wr_data => boot_data_out);


	sprite_mem_comp : VGA_MOTOR port map(
		vgaRed => vgaRed,
		vgaGreen => vgaGreen,
		vgaBlue	=> vgaBlue,
		Hsync => Hsync,
		Vsync => Vsync,
		clk => clk,
		rst => rst,  
		spriteWrite => spriteWrite,  
		--spriteType => spriteType,  
		spriteListPos => spriteListPos, 
		--spriteX => spriteX, 
		--spriteY => spriteY,
		spriteData => data_bus,
		spriteOut => sm_data_out 
	);
	

	prog_loader_comp : PROG_LOADER port map(
		clk => clk,
		rst => rst,
	 	rx => UART_in,
        boot_en => boot_en,
		done => boot_done,
	  	we => boot_we,
	  	addr => boot_addr,
	  	data_out => boot_data_out);

   -- uart_com_comp : UART_COM port map(
   --     clk => clk,
   --     rst => rst,
   --     send => com_send,
   --     bit_out => UART_out,
   --     send_byte => com_send_byte,
   --     sent => com_sent);

	reg_file_comp : REG_FILE port map(
		rd_in => IR2_rd,
		ra_in => IR2_ra,
		rd_out => rf_rd,
		ra_out => rf_ra,
		we => rf_we,
		data_in => data_bus,
		clk => clk,
        --led_out => led_null, -- turns of led to be set here
        led_out => led_value, -- set led value to led_addr in register file
        led_addr => led_addr);

	data_mem_comp : DATA_MEM port map(
		we => dm_we,
		addr => dm_addr,
		data_out => dm_data_out,
		data_in => data_bus,
		clk => clk
        --led_out => led_out,
        --led_addr => led_addr
	);

	alu_comp : ALU port map(
		MUX1 => alu_mux1,
		MUX2 => alu_mux2,
		op_code => IR2_op,
		result => alu_out,
		status_reg => status_reg_out,
        new_status_reg => new_status_reg,
		reset => rst,
		clk => clk);

	leddriver_comp : leddriver port map(
		clk => clk,
        rst => rst,
        seg => seg,
        an => an,
        value => led_value);

-------------------------------------------------------------------------------

    -- DEBUG
    -- 7 seg debug
    --led_value <= x"9A3C";

    -- UART debug
   -- process(clk) begin
   --     if (rising_edge(clk) and com_debug='1') then
   --         if (com_sent='1') then
   --             com_send_byte <= com_debug_value;
   --             com_send <= '1';
   --         elsif (com_send='1') then
   --             com_send <= '0';
   --             com_debug_value <= com_debug_value - 1;
   --         elsif (com_send <= '0' and com_debug_value = 0) then
   --             com_debug <= '0';
   --         end if;
   --     end if;
   -- end process;

    -- PM Debug
    ---
    -- Prints the contents of the program memory after the bootloader
    -- has loaded something to it.
--    process(clk) begin
--        if (rising_edge(clk) and boot_en='1') then
--            if (boot_we='1') then
--                com_pm_val <= boot_data_out;
--                com_send <= '1';
--            elsif (com_send='1') then
--                com_send <= '0';
--                com_debug_value <= com_debug_value - 1;
--            elsif (com_send <= '0' and com_debug_value = 0) then
--                com_debug <= '0';
--            end if;
--        end if;
--    end process;

	-- ALU multiplexers
	alu_mux1 <= rf_rd;

	alu_mux2 <= IR2_const 	when ((IR2_op = LDI)    	or
                                  (IR2_op = STI)    	or
								  (IR2_op = ADDI)   	or 
                                  (IR2_op = SUBI)   	or
								  (IR2_op = CMPI)   	or 
                                  (IR2_op = ANDI)   	or
								  (IR2_op = ORI)    	or 
								  (IR2_op = MULI)   	or
								  (IR2_op = MULSI)) 	else
				SP 		  	when  (IR2_op = POP)		or 
								  (IR2_op = PUSR)		or
								  (IR2_op = POSR)		or
								  (IR2_op = SUBR)		or
								  (IR2_op = PCR)		or
								  (IR2_op = PUSH)		else 
				rf_ra;

    new_status_reg <= data_bus(3 downto 0) when (IR2_op = POSR) else status_reg_out;

	-- Data bus multiplexer
    with IR2_op select
		data_bus <= rf_ra       				when ST,
					rf_rd						when PUSH,
					--dm_data_out			        when LD,
					--dm_data_out 		        when POP,
					--dm_data_out		            when POSR,
					--dm_data_out	    	        when PCR,
					dm_and_sm_data_out			when LD,
					dm_and_sm_data_out 		    when POP,
					dm_and_sm_data_out		    when POSR,
					dm_and_sm_data_out	    	when PCR,
                    IR2_const   				when STI,
					PC							when SUBR,
					x"000" & status_reg_out 	when PUSR,
					alu_out     				when others;

    -- slows clock
    dm_and_sm_data_out <= dm_data_out when (alu_out < x"FC00") else sm_data_out;
      
	-- Address controller
	dm_addr <= (alu_out and "0000000011111111"); -- Currently only allow 256 addresses
	dm_we <= '1' when ((alu_out < x"FC00") and ((IR2_op = STI) 		or 
												(IR2_op = ST) 		or 
												(IR2_op = PUSH) 	or 
												(IR2_op = PUSR) 	or 
												(IR2_op = SUBR))) 	else '0';

	
	-- sprite mem
	spriteListPos <= alu_out(4 downto 0);
	spriteWrite <= '1' when ((alu_out >= x"FC00") and ((IR2_op = STI) or (IR2_op = ST))) else '0'; 
	--spriteType 		<= data_bus(15 downto 13);
	--spriteX 		<= data_bus(12  downto 6);
	--spriteY			<= data_bus(5  downto 0);
	--spriteListPos <= "00000";
	--spriteWrite <= '1';
	--spriteType 		<= "001";
	--spriteX 		<= "0000000";
	--spriteY			<= "000000";


	-- Write enable RF
	rf_we <= '0' when ((IR2_op = NOP)   or
                       (IR2_op = RJMP)  or
                       (IR2_op = BEQ)   or
                       (IR2_op = BNE)   or
                       (IR2_op = BPL)   or
                       (IR2_op = BMI)   or
                       (IR2_op = BGE)   or
                       (IR2_op = BLT)   or
                       (IR2_op = STI)   or
                       (IR2_op = ST)    or
					   (IR2_op = CMP)	or
					   (IR2_op = CMPI)	or
					   (IR2_op = PUSR)	or 
					   (IR2_op = POSR)	or
					   (IR2_op = SUBR)	or
					   (IR2_op = PCR)	or
					   (IR2_op = RET)	or
                       (IR2_op = PUSH)) else '1';

	-- Handle PC:s and IR:s
	process(clk)
	begin
		if (rising_edge(clk)) then
			if (rst='1') then
				PC <= x"0001";
				PC1 <=  x"0001";
				JUMP_PC <= x"0001";
				IR1 <= (others => '0');
				IR2 <= (others => '0');

            -- proritize interrupts if one occurs
            elsif (interrupt='1' and interrupt_en='1' and interrupt_handling='0') then
                -- we save a flag to know we're handling an interrupt
                -- and give the opportunity to raise another one (which isn't handled)
                interrupt_handling <= '1';
                interrupt_handling_jump <= '1';
                
                -- jump to the interrupt vector by using a subroutine call 
                IR1_op <= SUBR;
                IR1_const <= x"0000";

            -- run as per usual when bootloader has loaded a program
			elsif (boot_done='1' or boot_en='0') then
				IR2 <= IR1;
				JUMP_PC <= PC1 + IR1_const; -- set JUMP_PC for potential jump in the future

                -- If we see a subroutine return, prepare for it
		        if (IR2_op = RET) then	
					IR2_op <= POSR;
					IR1_op <= PCR;

                -- PCR pops the stack unto the program counter
				elsif (IR2_op = PCR) then
                    -- special case if we're handling an interrupt since
                    -- the PC that is pushed into that stack is off by one
                    if (interrupt_handling='1') then
                        PC <= data_bus - 1;
                        interrupt_handling <= '0';
                    else
                        PC <= data_bus;
                    end if;

                    -- we clean the pipe in case there's some
                    -- jump instruction laying waiting to ruin things for us
                    IR1 <= (others => '0'); -- jump NOP
                    IR2 <= (others => '0'); -- jump NOP

                -- If we see a jump, prepare for it...
				-- Flags are not tested since they have not been set yet.
				-- This can lead to uneccesary NOPs but this is better than
				-- having to add NOPs manually
				elsif (IR1_op = RJMP) or
                      (IR1_op = BEQ)  or 
                      (IR1_op = BNE)  or
                      (IR1_op = BPL)  or
                      (IR1_op = BMI)  or
                      (IR1_op = BGE)  or
                      (IR1_op = SUBR) or
                      (IR1_op = BLT)  then
						 PC1 <= PC;

						 if (IR1_op = SUBR) then
							IR1_op <= PUSR;
							IR1_const <= x"0000";
							jumping <= '1';
						 else
						 	IR1 <= (others => '0'); -- jump NOP
						 end if;

                -- Don't increase PC if we're jumping
				elsif   (IR2_op = RJMP) 		    				or
						(IR2_op = SUBR)								or
					  	((IR2_op = BEQ) and ZF = '1') 				or
					    ((IR2_op = BNE) and ZF = '0') 				or
					    ((IR2_op = BPL) and NF = '0') 				or
					    ((IR2_op = BMI) and NF = '1') 				or
					    ((IR2_op = BGE) and ((NF xor VF) = '0')) 	or
					    ((IR2_op = BLT) and ((NF xor VF) = '1')) 	then

                    -- special case if subr call is from an interrupt, jump to intr vec
                    if (interrupt_handling_jump='1') then
                        PC <= x"0000";
                        interrupt_handling_jump <= '0';
                    else
                        PC <= JUMP_PC;
                    end if;


                -- Update as per usual if nothing special is happening
				else
					PC <= PC + 1;
					PC1 <= PC;

					IR1 <= PMdata_out;

					if jumping='1' then
						jumping <= '0';
					end if;
				end if;
			end if;
		end if;
	end process;

	pm_addr <= (PC and "0000011111111111"); -- Currently only allow 1024 addresses

	-- Update stack pointer
	-- If push: decrement
	-- If pop: increment
	process(clk)
	begin
		if rising_edge(clk) then
			if (rst='1') then
				SP <= x"00FF";
			elsif ((IR2_op = POP) or (IR2_op = POSR) or (IR2_op = PCR)) then
				SP <= SP + 1;
			elsif (IR2_op = PUSH or (IR2_op = PUSR) or (IR2_op = SUBR)) then
				if (jumping = '1') and (IR2_op = PUSR) then
					SP <= SP;
				else
					SP <= SP - 1;
				end if;
			end if;
		end if;
	end process;

end architecture;
