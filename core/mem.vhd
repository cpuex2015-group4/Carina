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
  type memt is array(0 to 65535) of datat;
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
--      current_xwa<=xwa;
      former_xwa<=xwa;
      forformer_xwa<=former_xwa;
      forforformer_xwa<=forformer_xwa;
--      current_addr<=ZA;
      former_addr<=ZA;
      forformer_addr<=former_addr;
      forforformer_addr<=forformer_addr;
    if former_xwa='0' then
      ZD<=Z;
    elsif forformer_xwa='0' then
      report "@mem" &Integer'image(conv_integer(ZD)) & "stored@" & Integer'image(conv_integer(forformer_addr(15 downto 0)));
      TEST_mem(conv_integer(forformer_addr(15 downto 0)))<=ZD;
    else
      report "loaded";
      report "@mem" &Integer'image(conv_integer(ZD)) & "loaded@" & Integer'image(conv_integer(forforformer_addr(15 downto 0)));
      report "memval=" & integer'image(conv_integer( TEST_mem(conv_INTEGER(forforformer_addr(15 downto 0)))));
      ZD<=TEST_mem(conv_INTEGER(forforformer_addr(15 downto 0)));
--      ZD<=x"cafecafe";
      mem_val<=TEST_mem(conv_INTEGER(forforformer_addr(15 downto 0)));
    end if;
  end if;
  end process;

  process(ZD)
  begin
    if ZD'event then
      report "@mem:ZD_changed:" & integer'image(conv_integer(ZD));
    end if;
  end process;
end kaze_ga_yabai_arashi;
