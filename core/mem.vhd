library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library UNISIM;
use UNISIM.VComponents.all;

library work;
use work.p_type.all;

entity mem is
port (
  ZD    : inout std_logic_vector(31 downto 0);
  ZA    : out   std_logic_vector(19 downto 0);
  XWA   : out   std_logic;
  clk   : out   std_logic;
  addr  : out   std_logic_vector(31 downto 0);
  read_data: out datat;
  send_data: in datat;
);
end mem;

architecture kaze_ga_yabai of mem is
  constant Z:std_logic_vector(19 downto 0):=(others=>'Z');
  
end kaze_ga_yabai;
