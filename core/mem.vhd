library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library UNISIM;
use UNISIM.VComponents.all;

library work;
use work.p_type.all;

entity mem_monkey is
port (
  ZD    : inout std_logic_vector(31 downto 0);
  ZA    : out   std_logic_vector(19 downto 0);
  XWA   : out   std_logic;
  clk   : out   std_logic
);
end mem_monkey;



-- kono jissouha gomidesu
--zenzen shuukiwo awasete imasen

architecture kaze_ga_yabai_arashi of mem_monkey is
  constant Z:std_logic_vector(19 downto 0):=(others=>'Z');
  signal test_mem:array(0 downto 255) of datat;@
begin
  if XWA='1' then
    ZD<=Z;
    mem(ZA(7 downto 0))<=ZD;
  else
    ZD<=mem(ZA(7 downto 0));
  end if;
end kaze_ga_yabai_arashi;
