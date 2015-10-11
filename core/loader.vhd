library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

library work;
use work.p_type.all;

entity loader is
  port (
    clk,IO_empty,IO,enable: in std_logic;
    IO_recv_data: in std_logic_vector(31 downto 0);
    IO_RE,finished: out std_logic
  );
end loader;

architecture kaisensionoodle of loader is
  type statet is (HEADER,TEXT_RECEIVING,DATA_RECEIVING,FINISHED);
  signal state:statet:=HEADER;
  signal text_size:datat;
  signal data_offset:datat;
  signal data_size:datat;
begin
  case (state) is
    when HEADER=>
      
    when TEXT_RECEIVING=>
    when DATA_RECEIVING=>
    when FINISHED=>
  end case;
end kaisensionoodle;

