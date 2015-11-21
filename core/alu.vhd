library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

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
        if (not operand1(31)) & operand1(30 downto 0)<(not operand2(31)) & operand2(30 downto 0) then
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
      when ALUDIV2 =>
        vresult:='0' & operand1(31 downto 1);
      when ALUMUL4 =>
        vresult:=operand1(29 downto 0) & "00";
    end case;
    result<=vresult;
    if vresult=x"00000000" then
      iszero<='1';
    else
      iszero<='0';
    end if;
  end process;
end pohe;
