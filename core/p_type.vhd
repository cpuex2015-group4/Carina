--
--	Package File Template
--
--	Purpose: This package defines supplemental types, subtypes, 
--		 constants, and functions 
--
--   To use any of the example code shown below, uncomment the lines and modify as necessary
--

library IEEE;
use IEEE.STD_LOGIC_1164.all;

package p_type is
  subtype datat is std_logic_vector(31 downto 0);
  subtype opet is std_logic_vector(5 downto 0);
  subtype regt is std_logic_vector(4 downto 0);
  subtype functt is std_logic_vector(5 downto 0);
  subtype imdt is std_logic_vector(15 downto 0);
  subtype addrt is std_logic_vector( 25 downto 0);
  type reg_filet is array(0 to 31) of datat;  

   type INST_TYPE is (I,R,J);
  type inst_file is record
    PC:datat;
    instruction:datat;
    opecode:opet;
    opetype:INST_TYPE;
    rs:regt;
    rt:regt;
    rd:regt;
    shamt:regt;
    funct:functt;
    immediate:imdt;
    addr:addrt;
  end record;

  type data_file is record
    operand1:datat;
    operand2:datat;
    result:datat;
  end record;
 type CORE_STATE_TYPE is (WAIT_HEADER,EXECUTING,HALTED);
  type EXE_STATE_TYPE is (F,D,EX,MEM,WB);
  type top_debug_out is record
    data1:datat;
    data2:datat;
    exe_state:EXE_STATE_TYPE;
    core_state:CORE_STATE_TYPE;
    PC:datat;
  end record;


  type control_file is record
                                --negate /assert
    RegDst:std_logic;           --rd->0 rt->1
    RegWrite:std_logic;         --we
    ALUSrc:std_logic;           --reg2/imd
    MemRead:std_logic;
    MemWrite:std_logic;
    MemtoReg:std_logic;
  end record;

  function make_control (opecode:opet) return control_file;

  type ALU_CONTROLT is (ALU_ADD,ALU_SUB,ALU_AND,ALU_OR,ALU_SLT)

-- procedure <procedure_nam >(<type_declaration> <constant_name>	: in <type_declaration>);
--

end p_type;

package body p_type is
  function make_control (opecode:opet) return control_file is
    variable control:control_file;
  begin
    if opecode ="000000" then
      control.RegDst:='0';
      control.ALUSrc:='0';
    else
      control.RegDst:='1';
      control.ALUSrc:='1';
    end if;

    if opecode="000000" or opecode="001000" or opecode="0001010"
      or opecode = "001011" or opecode ="001100" then
      control.RegWrite:='1';
    else
      control.RegWrite:='0';
    end if;

    if opecode=x"30" or opecode=x"23" then
      control.MemRead:='1';
      control.MemToReg:='1';
    else
      control.MemRead:='0';
      control.MemToReg:='0';
    end if;

    if opecode=x"2b" then
      control.MemWrite:='1';
    else
      control.MemWrite:='0';
    end if;

    return control;
  end make_control;
  
---- Example 1
--  function <function_name>  (signal <signal_name> : in <type_declaration>  ) return <type_declaration> is
--    variable <variable_name>     : <type_declaration>;
--  begin
--    <variable_name> := <signal_name> xor <signal_name>;
--    return <variable_name>; 
--  end <function_name>;

---- Example 2
--  function <function_name>  (signal <signal_name> : in <type_declaration>;
--                         signal <signal_name>   : in <type_declaration>  ) return <type_declaration> is
--  begin
--    if (<signal_name> = '1') then
--      return <signal_name>;
--    else
--      return 'Z';
--    end if;
--  end <function_name>;

---- Procedure Example
--  procedure <procedure_name>  (<type_declaration> <constant_name>  : in <type_declaration>) is
--    
--  begin
--    
--  end <procedure_name>;
 
end p_type;
