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
  shamt:in REGT;
  result:out datat;
  isZero:out std_logic
);
end alu;

architecture pohe of alu is
begin
  main:process(operand1,operand2,ALU_control)
    variable vresult:datat;
  begin
    assert false
      report "pohe";
    case (ALU_control) is
      when ALUADD =>
        vresult:=operand1+operand2;
      when ALUSUB =>
        vresult:=operand1-operand2;
      when ALUAND =>
        vresult:=operand1 and operand2;
      when ALUOR =>
        vresult:=operand1 or operand2;
      when ALUSLT =>
        if operand1<operand2 then
          vresult:=x"00000001";
        else
          vresult:=x"00000000";
        end if;
      when ALUNOR =>
        vresult:=operand1 nor operand2;
      when ALUSLL =>
        vresult:=SHL(operand1,shamt);
      when ALUSLR =>
        vresult:=SHR(operand1,shamt);
    end case;
    result<=vresult;
    iszero<='0';
    assert false
      report "pohe"
      severity note;
  end process;
end pohe;
