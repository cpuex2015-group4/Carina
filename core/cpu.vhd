library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

library UNISIM;
use UNISIM.VComponents.all;

library work;
use work.p_type.all;

entity cpu is
port (
  clk,IO_empty,IO_full: in std_logic;
  IO_recv_data: in std_logic_vector(31 downto 0);
  IO_WE,IO_RE: out std_logic;
  IO_send_data:out std_logic_vector(31 downto 0);
  DEBUG :out top_debug_out
);
end cpu;



----pohepohe architecture
----pipeline mo nanimo sitenai yo
----pipeline ga sitai naa



architecture RTL of cpu is

  component BRAM_INST
    port(
      addra: in datat;
      dina: in datat;
      wea: in  std_logic_vector(3 downto 0);
      clka:in std_logic;
      douta:out datat
    );
  end component;

  component alu
    port (
      operand1,operand2:in datat;
      ALU_control:in alu_controlt;
      shamt:in REGT;
      result:out datat;
      isZero:out std_logic
      );
end component;


  constant ZERO:datat:=x"00000000";
--zentaiseigyo kei
 
  signal PC :datat:=ZERO;
  signal reg_file:reg_filet:=(others=>ZERO);
  signal core_state:CORE_STATE_TYPE:=WAIT_HEADER;
  signal exe_state:EXE_STATE_TYPE:=F;
  signal inst_in:datat;
  signal inst_we:std_logic_vector(3 downto 0):="0000";
  signal inst_out:datat;
  signal inst_addr:datat;
  signal inst:inst_file;
  signal data:data_file;
  signal control:control_file;
signal alu_control:alu_controlt;

  --debug
  signal pohe:std_logic:='0';

--signal operand1:datat;-
--signal operand2:datat;
--signal alu_control:alu_controlt;
--signal shamt:regt;
signal result:datat;
--signal isZero:std_logic;


 --loader
  signal count:integer:=0;
  constant test_code_max:integer:=4;
  type test_code_t is array(0 to test_code_max) of datat; 
  constant test_code:test_code_t:=
    ( "00100000000000010000000000000100",
     "00100000000000100000000000001000",
     "00000000001000100000100000100000",
      CONV_STD_LOGIC_VECTOR(13,32),
      CONV_STD_LOGIC_VECTOR(14,32));
begin
  inst_mem:BRAM_INST port map(
    addra=>inst_addr,
    dina=>inst_in,
    wea=>inst_we,
    clka=>clk,
    douta=>inst_out
  );
  ALU_main:alu port map(
    operand1=>data.operand1,
    operand2=>data.operand2,
    alu_control=>alu_control,
    shamt=>inst.shamt,
    result=>result,
    isZero=>control.isZero);
  
  alu_control<=make_alu_control(inst.opecode,inst.funct);
  main:process (clk)
  variable instv:inst_file;
  variable controlv:control_file;
  begin
  if rising_edge(clk) then  
  case (core_state) is
    when WAIT_HEADER =>
      --debug
      DEBUG.data1<=inst_out;
      DEBUG.core_state<=core_state;
      DEBUG.PC<=CONV_STD_LOGIC_VECTOR(count,32);
      DEBUG.control<=control;
      --/debug


      count<=count+1;
      if count<=test_code_max then
        inst_addr<=CONV_STD_LOGIC_VECTOR(count,32);
        inst_in<=test_code(count);
        inst_we<="1111";
      else 
        inst_we<="0000";
        inst_addr<=PC;
        if count=test_code_max+10 then
          core_state<=EXECUTING;
        end if;
      end if;
    when EXECUTING =>
  --debug
  DEBUG.opecode<=inst.opecode;
  DEBUG.control<=control;
  
  DEBUG.data<=data;
  DEBUG.data1<=reg_file(1);
  DEBUG.data2<=reg_file(2);
  DEBUG.exe_state<=exe_state;
  DEBUG.core_state<=core_state;
  DEBUG.PC<=PC;
  DEBUG.inst<=inst;
  DEBUG.data3<=result;
  DEBUG.alucont<=alu_control;
  --/debug
      
      case ( exe_state) is
        when F =>
          instv.PC:=PC;
          instv.instruction:=inst_out;
          instv.opecode:= inst_out(31 downto 26);
          instv.rs:=inst_out(25 downto 21);
          instv.rt:=inst_out(20 downto 16);
          instv.rd:=inst_out(15 downto 11);
          instv.shamt:=inst_out(10 downto 6);
          instv.funct:=inst_out(5 downto 0);
          instv.immediate:=inst_out(15 downto 0);
          instv.addr:=inst_out(25 downto 0);
          inst<=instv;
          exe_state<=D;
        when D =>
          exe_state<=EX;
          instv:=inst;
          controlv:=make_control(inst.opecode);
          if controlv.RegDst='0' then
            instv.reg_dest:=instv.rd;
          else
            instv.reg_dest:=instv.rt;
          end if;
          inst<=instv;
          data.operand1<=reg_file(CONV_INTEGER(inst.rs));
          if controlv.ALUSrc='0' then
            data.operand2<=reg_file(CONV_INTEGER(inst.rt));
          else
            data.operand2<="0000000000000000" & inst.immediate;
          end if;
          control<=controlv;
        when EX =>
          exe_state<=MEM;

--          operand1<=data.operand1;
--          operand2<=data.operand2;
--          alu_control<=make_alu_control(inst.opecode,inst.funct);
--          shamt<=inst.shamt;
          data.result<=result;
        when MEM =>
          exe_state<=WB;
        when WB =>
           if control.RegWrite='1' then
             if inst.reg_dest /= x"00000" then
               reg_file(CONV_INTEGER(inst.reg_dest))<=data.result;
             end if;
           end if;
          exe_state<=F;
        -- end if;
         
          PC<=PC+x"00000001";
          inst_addr<=PC+x"00000001";
      end case;
    when HALTED =>
      -- do nothing;
  end case;
  end if;
  end process;
end RTL;
