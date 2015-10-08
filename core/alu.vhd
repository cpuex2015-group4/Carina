library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

library UNISIM;
use UNISIM.VComponents.all;

library work;
use work.p_type.all;

entity alu is
port (
  operand1,operand2:in datat;
  ALU_control:in alu_controlt;
  result:out datat;
  isZero:out std_logic
);
end alu;

architecture pohe of alu is
  main:procedure(operand1,operand2,ALU_control)
    variable vresult:datat;
  begin
    case (ALU_control) is
    when ALU_AND =>
    vresult:=operand1+operand2;
    when ALU_SUB =>
    
    end case;
  end procedure;
end pohe;
