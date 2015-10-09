--This is a wrapper of IO_unit
--IO_unit allows us to IOing with 8-bit data.
--This will buffer them and provides the 32-bit IO-ing interface.

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity IO32 is
  port(
    clk,WE,RE:in                std_logic;
    send_data:in                std_logic_vector(7 downto 0);
    recv_data:out               std_logic_vector(7 downto 0);
    full,empty:out              std_logic;
    serial_send:out             std_logic;
    serial_recv:in              std_logic
    );
end IO32;

IO_module is
  port(
    clk,WE,RE:in                std_logic;
    send_data:in                std_logic_vector(7 downto 0);
    recv_data:out               std_logic_vector(7 downto 0);
    full,empty:out              std_logic;
    serial_send:out             std_logic;
    serial_recv:in              std_logic
    );
end IO_module;


