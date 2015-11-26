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
  ZD    : inout std_logic_vector(31 downto 0):=(others=>'Z');
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
  signal test_mem:memt:=(others=>x"FFFFFFFF");
  signal former_xwa:std_logic:='1';
  signal forformer_xwa:std_logic:='1';
  signal forforformer_xwa:std_logic:='1';
  signal former_addr:std_logic_vector(19 downto 0):=(others=>'0');
  signal forformer_addr:std_logic_vector(19 downto 0):=(others=>'0');
  signal forforformer_addr:std_logic_vector(19 downto 0):=(others=>'0');
  signal mem_val:datat;
begin
--    ZD<=Z when forformer_xwa='0'or former_xwa='0' or xwa='0' else
--          TEST_mem(conv_INTEGER(forforformer_addr(7 downto 0)));
  process(clk)
  begin
  if rising_edge(clk) then
    
  end process;
end kaze_ga_yabai_arashi;
