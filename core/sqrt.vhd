   --sqrt.vhd
   --情報科学科 05-151007 今井雄毅
   --Sun Nov 22 23:09:36 2015

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
library work;
use p_type.all;


entity sqrt is
  port(
    input:in datat;
    output:out datat:=(OTHERS=>'0')
  );
end sqrt;

architecture ARCHITECTURE_NAME of sqrt is
  --constants
  constant MAGIC_NUMBER:datat:=x"5f3759df";
  constant THREEHALFS:datat:=x"3fc00000";
  --initial_values
  --components

  --signals
  signal half:datat:=(others=>'0');
  signal subt:datat:=(others=>'0');
begin
  half<='0' & (input(30 downto 23) -1) & input(22 downto 0);
  subt<=magic-('0' & input(30 downto 0));
  output<=subt*(THREEHALFS-(half*subt*subt));
end ARCHITECTURE_NAME;
