library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity ADDR_CONT is
  port (
    address : in unsigned(15 downto 0);
    data_out : out unsigned(15 downto 0)
  );
