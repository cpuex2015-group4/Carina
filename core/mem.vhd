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
  ZA    : in   std_logic_vector(19 downto 0);
  XWA   : in   std_logic;
  clk   : in   std_logic
);
end mem_monkey;



-- kono jissouha gomidesu
--zenzen shuukiwo awasete imasen

architecture kaze_ga_yabai_arashi of mem_monkey is
  constant Z:datat:=(others=>'Z');
  type memt is array(0 to 255) of datat;
  signal test_mem:memt;
begin
  process(clk)
  begin
  if falling_edge(clk) then
  if XWA='1' then
    ZD<=Z;
    TEST_mem(conv_integer(ZA(7 downto 0)))<=ZD;
  else
    ZD<=TEST_mem(conv_INTEGER(ZA(7 downto 0)));
  end if;
  end if;
  end process;
end kaze_ga_yabai_arashi;
