library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

library work;
use work.p_type.all;

entity cpu is
port (
  clk,IO_empty,IO_full: in std_logic;
  IO_recv_data: in std_logic_vector(31 downto 0);
  IO_WE,IO_RE: out std_logic;
  IO_send_data:out std_logic_vector(31 downto 0);
  DEBUG :out top_debug_out
);
end cpu;



----pohepohe architecture
----pipeline mo nanimo sitenai yo
----pipeline ga sitai naa



architecture RTL of cpu is

begin
  IO_WE<='0';
  IO_RE<='0';
  IO_send_data<=x"00000000";
end RTL;
