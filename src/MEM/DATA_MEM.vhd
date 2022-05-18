library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity DATA_MEM is
    port(
        clk : std_logic;
        addr : in unsigned(15 downto 0);
        data_out : out unsigned(15 downto 0);
        data_in : in unsigned(15 downto 0);
        we : in std_logic);
end DATA_MEM;

architecture func of DATA_MEM is

    type DM_t is array(0 to 1023) of unsigned(15 downto 0);
    constant DM_c : DM_t := (
        others => (others => '0')
    );

    signal DM : DM_t := DM_c;
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if (we = '1') then
                DM(to_integer(addr)) <= data_in;
            end if;
        end if;
    end process;

    data_out <= DM(to_integer(addr));
end func;
