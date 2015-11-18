library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library work;
use work.p_type.all;

entity BRAM_INST is
  port(
    addra: in datat;
    dina: in datat;
    wea: in std_logic_vector(3 downto 0);
    clka:in std_logic;
    douta:out datat
    );
end BRAM_INST;


architecture pohe of BRAM_INST is
  type mem_t is array(0 to 20000) of datat;
  signal memory:mem_t:=(others=>x"00000000");
begin
  process(addra,dina,wea,clka)
  begin
    douta<=memory(CONV_INTEGER(addra(4 downto 0)));
    if wea(0)='1' then
      memory(CONV_INTEGER(addra(4 downto 0)))<=dina;
    end if;
  end process;
end pohe;
