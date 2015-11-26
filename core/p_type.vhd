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

  
  constant BRAM_ADDR_SIZE:integer:=15;
  subtype BRAM_ADDRT is std_logic_vector(BRAM_ADDR_SIZE-1 downto 0);
  subtype datat is std_logic_vector(31 downto 0);
  subtype opet is std_logic_vector(5 downto 0);
  subtype regt is std_logic_vector(4 downto 0);
  subtype functt is std_logic_vector(5 downto 0);
  subtype imdt is std_logic_vector(15 downto 0);
  subtype addrt is std_logic_vector( 25 downto 0);
  subtype memaddrt is std_logic_vector(19 downto 0);


--ISA------------------------------------------------------------------
  constant OP_REGREG    :opet:="000000";
  constant OP_J         :opet:="000010";
  constant OP_JAL       :opet:="000011";
  constant OP_BEQ       :opet:="000100";
  constant OP_BNE       :opet:="000101";
  constant OP_ADDI      :opet:="001000";
  constant OP_ORI       :opet:="001101";
  constant OP_SLTI      :opet:="001010";
  constant OP_ANDI      :opet:="001100";
  constant OP_LW        :opet:="100011";
  constant OP_SW        :opet:="101011";

  constant OP_FP        :opet:="010001";
  constant OP_LWCL      :opet:="110001";
  constant OP_SWCL      :opet:="111001";

  constant OP_IN        :opet:="011010";
  constant OP_OUT       :opet:="011011";
  constant OP_HLT       :opet:="111111";
  
  
--/ISA-----------------------------------------------------------------




  type reg_filet is array(0 to 31) of datat;
  type PC_controlt is (j,jr,b,normal);
  type INST_TYPE is (I,R,J);
  type inst_file is record
    PC:datat;
    instruction:datat;
    opecode:opet;
    opetype:INST_TYPE;
    rs:regt;
    rt:regt;
    rd:regt;
    reg_dest:regt;
    --   reg_source:regt;
    shamt:regt;
    funct:functt;
    immediate:imdt;
    addr:addrt;
    memaddr:memaddrt;
  end record;

  type data_file is record
    operand1:datat;
    operand2:datat;
    result:datat;
    newPC:datat;
  end record;
  type CORE_STATE_TYPE is (INIT,WAIT_HEADER,EXE_READY,EXECUTING,HALTED);
  type EXE_STATE_TYPE is (F,D,EX,MEM,WB);

  type control_file is record
    --negate /assert
    RegDst:std_logic;           --rd->0 rt->1
    RegWrite:std_logic;         --we
    ALUSrc:std_logic;           --reg2/imd
    MemRead:std_logic;
    MemWrite:std_logic;
    IORead:std_logic;
    IOWrite:std_logic;
    MemtoReg:std_logic;
    isZero:std_logic;
    fpu_data:std_logic;
    PC_control:PC_controlt;
  end record;


  function make_control (opecode:opet;fmt:regt;funct:functt) return control_file;

  type ALU_CONTROLT is (ALUADD,ALUSUB,ALUAND,ALUOR,ALUDIV2,ALUMUL4,ALUSLT,ALUNOR,ALUSLL,ALUSLR);
  type FPU_CONTROLT is (FADD,FSUB,FMUL,FINV,FCOMP);
  
  function make_alu_control(opecode:opet; funct:functt) return ALU_CONTROLT;
  function sign_extension(imd:imdt) return memaddrt;

  type detail_debug_info is record
    exe_state:EXE_STATE_TYPE;
    core_state:CORE_STATE_TYPE;
    alucont:ALU_CONTROLT;
    control:control_file;
    opecode:opet;
    inst:inst_file;
  end record;  
  
  type top_debug_out is record
    PC:datat;
    ra:datat;
    v0:datat;
    t0:datat;
    t1:datat;
    f1:datat;
    f2:datat;
    f3:datat;
    f4:datat;
    f5:datat;
    f6:datat;
    f7:datat;
    gp:datat;
    sp:datat;
    fp:datat;
    at:datat;
    FPCond:std_logic;
    data:data_file;
    detail:detail_debug_info;
  end record;
  
-- procedure <procedure_nam >(<type_declaration> <constant_name>	: in <type_d@eclaration>);
--

end p_type;

package body p_type is
  function make_control (opecode:opet;fmt:regt;funct:functt) return control_file is
    variable control:control_file;
  begin
    if opecode ="000000" OR opecode="011011" or opecode="000100" or opecode="000101"  or opecode="010001" then
      control.RegDst:='0';
      control.ALUSrc:='0';
    else
      control.RegDst:='1';
      control.ALUSrc:='1';
    end if;

    if opecode="000000" or opecode="001000" or opecode="001010"
      or opecode = "001011" or opecode ="001100" or opecode = "011010" or opecode = "100011" or opecode="110001" or opecode="010001" then
      control.RegWrite:='1';
    else
      control.RegWrite:='0';
    end if;

    if opecode="110000" or opecode="100011" or opecode="110001" then
      control.MemRead:='1';
      control.MemToReg:='1';
    else
      control.MemRead:='0';
      control.MemToReg:='0';
    end if;

    if opecode="101011" or opecode="111001" then
      control.MemWrite:='1';
    else
      control.MemWrite:='0';
    end if;

    case (opecode) is
      when "000100" | "000101"   =>
        control.PC_control:=b;
      when "000010" | "000011" =>
        control.PC_control:=j;
      when "000000" =>
        if funct="001000" or funct="001001" then
          control.PC_control:=jr;
        else
          control.PC_control:=normal;
        end if;
      when "010001" =>
        if fmt="01000" then
          control.PC_control:=b;
        else
          control.PC_control:=normal;
        end if;
      when others=>
        control.PC_control:=normal;
    end case;

    if opecode="011010" then
      control.IORead:='1';
    else
      control.IORead:='0';
    end if;
    
    if opecode="011011" then
      control.IOWrite:='1';
    eLSE
      control.IOWrite:='0';
    end if;
    if opecode="010001" then
      control.fpu_data:='1';
    else
      control.fpu_data:='0';
    end if;

    return control;

  end make_control;

  function make_alu_control(opecode:opet;funct:functt) return ALU_CONTROLT is
    variable AC:ALU_CONTROLT;
  begin
    if(opecode="000000") then
      case (funct) is
        when "100000" =>
          AC:=ALUADD;
        when "100010" =>
          AC:=ALUSUB;
        when "100100" =>
          AC:=ALUAND;
        when "100101" =>
          AC:=ALUOR;
        when "101010" =>
          AC:=ALUSLT;
        when "100111" =>
          AC:=ALUNOR;
        when "000000" =>
          AC:=ALUSLL;
        when "000010" =>
          AC:=ALUSLR;
        when "011010" =>
          AC:=ALUDIV2;
        when "011000" =>
          AC:=ALUMUL4;
        when others =>
      end case;
    else
      case (opecode) is
        when "001000" =>
          AC:=ALUADD;
        when "001100" =>
          AC:=ALUAND;
        when "001101" =>
          AC:=ALUOR;
        when "001010" =>
          AC:=ALUSLT;
        when others =>
          AC:=ALUSUB;
      end case;
    end if;
    return AC;
  end make_alu_control;


  function sign_extension(imd:imdt) return memaddrt is
    variable s:std_logic;
  begin
    s:=imd(15);
    return s & s & s & s & imd;
  end sign_extension;
  
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
