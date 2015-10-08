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


  --debug
  signal pohe:std_logic:='0';

 --loader
  signal count:integer:=0;
  constant test_code_max:integer:=2;
  type test_code_t is array(0 to test_code_max) of datat; 
  constant test_code:test_code_t:=
    ( "00100000000000010000000000000100",
      "00100000000000100000000000001000",
      "00000000001000100000100000100000");
begin
  inst_mem:BRAM_INST port map(
    addra=>inst_addr,
    dina=>inst_in,
    wea=>inst_we,
    clka=>clk,
    douta=>inst_out
  );

  

  main:process (clk)
  variable instv:inst_file;
  begin
  if rising_edge(clk) then  
  case (core_state) is
    when WAIT_HEADER =>
      if pohe='0' then
        inst_we<="1111";
        inst_addr<=conv_std_logic_vector(count,32);
        inst_in<=conv_std_logic_vector(count,32);
        if count>10 then
          count<=0;
          pohe<='1';
          inst_we<="0000";
        else
          count<=count+1;
        end if;
      else
        count<=count+1;
        inst_addr<=conv_std_logic_vector(count,32);
      end if;
      debug.PC<=conv_std_logic_vector(count,32);
      debug.data1<=inst_out;
      debug.data2<="000000000000000000000000000" & inst_we & pohe;
    when EXECUTING =>
  --debug
  DEBUG.data1<=inst.instruction;
  DEBUG.data2<=reg_file(1);
  DEBUG.exe_state<=exe_state;
  DEBUG.core_state<=core_state;
  DEBUG.PC<=PC;
  --/debug
      
      case ( exe_state) is
        when F =>
          inst.instruction<=inst_out;
        exe_state<=D;
        when D =>
          instv.PC:=PC;
          instv.instruction:=inst.instruction;
          instv.opecode:= inst.instruction(31 downto 26);
          instv.rs:=inst.instruction(25 downto 21);
          instv.rt:=inst.instruction(20 downto 16);
          instv.rd:=inst.instruction(15 downto 11);
          instv.shamt:=inst.instruction(10 downto 6);
          instv.funct:=inst.instruction(5 downto 0);
          instv.immediate:=inst.instruction(15 downto 0);
          instv.addr:=inst.instruction(25 downto 0);
          inst<=instv;
          exe_state<=EX;


        -- add kimeuchi check
          data.operand1<=reg_file(CONV_INTEGER(instv.rs));
          if control.ALUSrc='0' then
            data.operand2<=reg_file(CONV_INTEGER(instv.rt));
          else
            data.operand2<="0000000000000000" & inst.immediate;
          end if;
        when EX =>
          exe_state<=MEM;
        --add kimeuchi check
          data.result<=data.operand1+data.operand2;
        when MEM =>
          exe_state<=WB;
        --do nothing
        when WB =>
           if control.RegWrite='1' then
             if inst.rd /= x"00000" then
               if control.RegDst='0' then
                 reg_file(CONV_INTEGER(inst.rd))<=data.result;
               else
                 reg_file(CONV_INTEGER(inst.rt))<=data.result;
               end if;
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
