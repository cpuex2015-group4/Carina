library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library work;
use work.p_type.all;

entity finv is
  port(
    input:in datat;
    output:out datat
    );
end finv;

architecture stub of finv is
begin
  output<=x"0F0FBEEF";
end stub;


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library work;
use work.p_type.all;

entity fcmp is
  port(
    inputa:in datat;
    inputb:in datat;
    funct:in functt;
    output:out std_logic
    );
end fcmp;

architecture stub of fcmp is
begin
  output<='0';
end stub;
