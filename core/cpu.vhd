library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

library work;
use work.p_type.all;

entity cpu is
port (
  clk,IO_empty,IO_full: in std_logic;
  IO_recv_data: in std_logic_vector(31 downto 0);
  IO_WE,IO_RE: out std_logic:='0';
  IO_send_data:out std_logic_vector(31 downto 0):=x"00000000";
  word_access:out std_logic:='1';
  --SRAM
  SRAM_ADDR:out std_logic_vector(19 downto 0):="00000000000000000000";
  SRAM_DATA:inout datat:="ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
  SRAM_WE:out std_logic:='1';

  --DEBUG
 DEBUG :out top_debug_out
);
end cpu;



----pohepohe architecture
----pipeline mo nanimo sitenai yo
----pipeline ga sitai naa

architecture RTL of cpu is

  constant IS_DEBUG:boolean:=true;
  constant IS_SIM:boolean:=false;
  component BRAM_INST
    port(
      addra: in BRAM_ADDRT;
      dina: in datat;
      wea: in  std_logic_vector (0 downto 0);
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
  component loader
    port (
      clk,IO_empty,activate: in std_logic;
      IO_recv_data: in std_logic_vector(31 downto 0);
      addr:out BRAM_ADDRT;
      din:out datat;
      bram_we:out std_logic_vector(0 downto 0);
      SRAM_ADDR:out std_logic_vector(19 downto 0):="00000000000000000000";
      SRAM_DATA:inout datat:="ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
      SRAM_WE:out std_logic:='1';
      entry:out datat;
      IO_RE,loaded: out std_logic:='0';
      heap_head:out datat;
      reset:in std_logic:='0'
      );
  end component;

  component fpu    --single しか使わないので fmt は省いてあります
    port (
      clk:in std_logic;
      funct:in functt;
      data1: in datat:=x"00000000";
      data2: in datat:=x"00000000";
      result:out datat:=x"00000000";
      FPCond:out std_logic:='0'
      );
  end component;

  constant ZERO:datat:=x"00000000";
--zentaiseigyo kei

  signal PC :datat:=ZERO;
  signal reg_file:reg_filet:=(others=>ZERO);
  signal fpu_reg_file:reg_filet:=(others=>ZERO);
  signal FPCOND:std_logic;

  signal core_state:CORE_STATE_TYPE:=INIT;
  signal exe_state:EXE_STATE_TYPE:=F;
  signal inst_in:datat;
  signal inst_we:std_logic_vector(0 downto 0):="0";
  signal inst_out:datat;
  signal inst_addr:BRAM_ADDRT;
  signal inst:inst_file;
  signal data:data_file;
  signal control:control_file;
  signal io_re_cpu:std_logic:='0';
  signal alu_control:alu_controlt;

  --debug
  signal pohe:std_logic:='0';
  signal total_instruction:datat:=ZERO;
--signal operand1:datat;-
--signal operand2:datat;
--signal alu_control:alu_controlt;
--signal shamt:regt;
signal result:datat;
signal isZero:std_logic;


 --loader
  signal loader_activate: std_logic:='0';
  signal loader_addr: BRAM_ADDRT;
  signal loader_din: datat;
  signal loader_IO_RE,loaded: std_logic:='0';
  signal entry_point:datat;
  signal loader_reset:std_logic:='1';
  signal loader_SRAM_ADDR: std_logic_vector(19 downto 0):="00000000000000000000";
  signal loader_SRAM_DATA: datat:="ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
  signal loader_SRAM_WE:std_logic:='1';
  signal heap_head:datat;
-- 
  constant memory_write_wait:std_logic_vector(2 downto 0):="010";
  constant memory_read_wait:std_logic_vector(2 downto 0):="101";
  signal memory_count:std_logic_vector(2 downto 0):="000";


--fpu
constant fpu_wait_max:std_logic_vector(2 downto 0):="010";
signal fpu_wait:std_logic_vector(2 downto 0):="000";
signal fpu_funct:functt:="000000";
signal fpu_data1:datat:=x"00000000";
signal fpu_data2:datat:=x"00000000";
signal fpu_result:datat:=x"00000000";
signal fpu_FPCond:std_logic:='0';
  
  signal count:integer:=0;
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
    isZero=>isZero);

  fpu_main: fpu    --single しか使わないので fmt は省いてあります
   port map(
     clk,
      fpu_funct,
      fpu_data1,
      fpu_data2,
      fpu_result,
      fpu_FPCond
      );

 

  lod:loader port map(
    clk=>clk,
	 IO_empty=>IO_empty,
	 activate=>loader_activate,
	 IO_RECV_DATA=>IO_recv_data,
	 addr=>loader_addr,
	 din=>inst_in,
	 bram_we=>inst_we,
    sram_addr=>loader_sram_addr,
    sram_data=>loader_sram_data,
    sram_we=>loader_sram_we,
     entry=>entry_point,
	 io_re=>loader_io_re,
    heap_head=>heap_head,
	 loaded=>loaded,
     reset=>loader_reset);

  alu_control<=make_alu_control(inst.opecode,inst.funct);

  inst_addr<=loader_addr(BRAM_ADDR_SIZE-1 downto 0) when core_state=WAIT_HEADER else
              PC(BRAM_ADDR_SIZE-1 downto 0);

  io_re<=loader_io_re when core_state=Wait_header else
			io_re_cpu;
  main:process (clk)
    variable instv:inst_file;
    variable controlv:control_file;
    variable vPC:datat;
  begin
    if rising_edge(clk) then
      case (core_state) is
        when INIT=>
          total_instruction<=ZERO;
          loader_reset<='0';

          if IS_DEBUG then
            if io_full='0' then
              io_we<='1';
              io_send_data<=x"4341524e";
            else
              io_we<='0';
              core_state<=WaIT_HEADER;
            end if;
          else
            core_state<=WaIT_HEADER;
            io_we<='0';
          end if;
        when WAIT_HEADER =>
      --debug
          DEBUG.detail.core_state<=core_state;
          DEBUG.PC<=CONV_STD_LOGIC_VECTOR(count,32);
          DEBUG.detail.control<=control;
      --/debug


          sram_data<=loader_sram_data;
          sram_addr<=loader_sram_addr;
          sram_we<=loader_sram_we;
          loader_activate<='1';
          if loaded='1' then
            if IS_DEBUG then
              io_send_data<=x"52435644";
              IO_WE<='1';
            end if;
            PC<=entry_point;
            core_state<=EXE_READY;
--       else
--        io_send_data<=io_recv_data;
--        io_we<=loader_io_re;
          end if;
        when EXE_READY=>
          reg_file(29)<="00000000000011111111111111111111";   --sp=mem_max;
          reg_file(28)<=heap_head; --gp=heap_head
          io_we<='0';
          word_access<='0';
          report "exe ready";
          core_state<=EXECUTING;    --data source no kirikae
        when EXECUTING =>
      --debug
          DEBUG.detail.opecode<=inst.opecode;
          DEBUG.detail.control<=control;

          DEBUG.data<=data;
          DEBUG.t0<=reg_file(8);
          DEBUG.t1<=reg_file(9);
          DEBUG.v0<=reg_file(2);
          DEBUG.f1<=fpu_reg_file(1);
          DEBUG.f2<=fpu_reg_file(2);
          DEBUG.f3<=fpu_reg_file(3);
          DEBUG.f4<=fpu_reg_file(4);
          DEBUG.f5<=fpu_reg_file(5);
          DEBUG.f6<=fpu_reg_file(6);
          DEBUG.f7<=fpu_reg_file(7);
          DEBUG.fp<=reg_file(30);
          DEBUG.gp<=reg_file(28);
          DEBUG.sp<=reg_file(29);
          DEBUG.ra<=reg_file(31);
          DEBUG.at<=reg_file(1);
          DEBUG.detail.exe_state<=exe_state;
          DEBUG.detail.core_state<=core_state;
          DEBUG.PC<=PC;
          DEBUG.detail.inst<=inst;
          DEBUG.detail.alucont<=alu_control;
          DEBUG.FPCond<=FPcond;
  --/debug

          case ( exe_state) is
            when F =>
              total_instruction<=total_instruction+x"00000001";
--		    report "inst_out:" & integer'image(conv_integer(inst_out));
--			 report "PC:" &  integer'image(conv_integer(PC));
-- ###################################DEBUG############################
--			 if io_full='0' then
--				io_we<='1';
--				io_send_data<=inst_out;
--				exe_state<=D;
--			 end if;

--        when D =>
--				io_we<='0';
--#####################################################################
              exe_state<=D;
            when D=>
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
              exe_state<=EX;
              if inst_out=x"FFFFFFFF" then-------------------------------hlt
               core_state<=HALTED;
                loader_reset<='1';
                word_access<='1';
                exe_state<=F;
              end if;
              controlv:=make_control(instv.opecode,instv.rs,instv.funct);
              if controlv.RegDst='0' then
                if controlv.fpu_data='0' then
                  instv.reg_dest:=instv.rd;
                else
                  instv.reg_dest:=instv.shamt;
                end if;
              else
                instv.reg_dest:=instv.rt;
              end if;
              inst<=instv;
              if controlv.fpu_data='0' then
                data.operand1<=reg_file(CONV_INTEGER(instv.rs));
              else
                data.operand1<=fpu_reg_file(CONV_INTEGER(instv.rd));
              end if;

              if controlv.ALUSrc='0' then
                if controlv.fpu_data='0' then
                  data.operand2<=reg_file(CONV_INTEGER(instv.rt));
                else
                  data.operand2<=fpu_reg_file(CONV_INTEGER(instv.rt));
                end if;
              else
                if instv.immediate(15) ='0' then
                  data.operand2<="0000000000000000" & instv.immediate;
                else
                  data.operand2<="1111111111111111" & instv.immediate;
                end if;
              end if;
              control<=controlv;
            when EX =>
              if control.fpu_data='1' then
                fpu_data1<=data.operand1;
                fpu_data2<=data.operand2;
                fpu_funct<=inst.funct;
                if fpu_wait<fpu_wait_max then
                  fpu_wait<=fpu_wait+"001";
                else
                  data.result<=fpu_result;
                  exe_state<=MEM;
                  fpu_wait<="000";
                  if inst.funct(5 downto 4)="11" then
                    FPCOND<=fpu_FPCOND;
                  end if;
                end if;
              else
                exe_state<=MEM;
                 data.result<=result;
             end if;
--          operand1<=data.operand1;
--          operand2<=data.operand2;
--          alu_control<=make_alu_control(inst.opecode,inst.funct);
--          shamt<=inst.shamt;





              case (control.PC_control) is
                when normal =>
                  data.newPC<=PC+1;
                when b=>
                  if inst.immediate(15)='0' then
                    report "PLUS";
                    data.newPC<=PC+1+("0000000000000000" & inst.immediate);
                  else
                    report "MINUS";
                    data.newPC<=PC+1+("1111111111111111" & inst.immediate);
                  end if;
                when j=>
                  data.newPC<="0000000000000000"&inst.immediate;
                when jr =>
                  data.newPC<=reg_file(CONV_INTEGER(inst.rs));
              end case;
          --memaddr
              inst.memaddr<=data.operand1(19 downto 0)+sign_extension(inst.immediate);
            when MEM =>
              control.iszero<=iszero;
              if control.IORead='1' then
                if IO_empty='0'then
                  data.result<=IO_recv_data;
                  IO_re_cpu<='1';
                  exe_state<=WB;
                end if;
              elsif control.IOWrite='1' then
                if IO_full='0' then
                  IO_we<='1';
                  IO_send_data<=data.operand2;
                  exe_state<=WB;
                end if;
              elsif control.Memwrite='1' then
                case (memory_count) is
                  when "000" =>
                    SRAM_ADDR<=inst.memaddr;
                    SRAM_WE<='0';
                    memory_count<=memory_count+"001";
                    sram_data<="ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
                  when memory_write_wait =>
                    sram_we<='1';
                    memory_count<="000";
                    if inst.opecode/="111001" then
                      sram_data<=reg_file(conv_integer(inst.rt));
                    else
                      sram_data<=fpu_reg_file(conv_integer(inst.rt));
                    end if;
                    exe_state<=WB;
                  when others=>
                    SRAM_WE<='1';
                    SRAM_DATA<="ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
                    memory_count<=memory_count+"001";
                end case;
              elsif control.MemRead='1' then
                report "memread";
                case (memory_count) is
                  when "000" =>
                    SRAM_ADDR<=inst.memaddr;
                    SRAM_DATA<="ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
                    memory_count<=memory_count+"001";
                  when memory_read_wait =>
                    memory_count<="000";
                    data.result<=SRAM_DATA;
                    exe_state<=WB;
                  when others=>
                    memory_count<=memory_count+"001";
                end case;
              else
                exe_state<=WB;
              end if;
            when WB =>
              IO_re_cpu<='0';
              IO_we<='0';
              SRAM_DATA<="ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
              if control.RegWrite='1' then
                if inst.reg_dest /= x"00000" then
                  if inst.opecode="010001" or inst.opecode="110001" then  --flu(0x11) and lw.s(0x31)
                    fpu_reg_file(CONV_INTEGER(inst.reg_dest))<=data.result;
                  else
                      reg_file(CONV_INTEGER(inst.reg_dest))<=data.result;
                  end if;
                end if;
              end if;
              exe_state<=F;
              if inst.opecode="000011" or (inst.opecode="000000" and inst.funct="01001") then  --jal,jral
                reg_file(31)<=PC+x"00000001";
                report "j_l";
              end if;
              case (control.PC_control) is
                when normal =>
                  vPC:=PC+x"00000001";
                when j| jr =>
                  vPC:=data.newPC;
                when b =>
                  if (inst.opecode="000100" and control.isZero='1') or
                    (inst.opecode="000101" and control.isZero='0') or
                    (inst.opecode="010001" and inst.rs="01000" and ((inst.rt="00001" and FPCond='1')or (inst.rt="00000" and FPCond='0')))
                  then
                    vPC:=data.newPC;
                  else
                    vPC:=PC+x"00000001";
                  end if;
              end case;
              PC<=vPC;
          end case;
        when HALTED =>
      -- do nothing

          if IS_SIM then
            assert false report "Halted" severity failure;
          end if;
          
--          if IS_DEBUG then
--            if IO_full='0' then
--              IO_we<='1';
--              IO_send_data<=total_instruction;
--              core_state<=INIT;
--              exe_state<=WB;
--            else
--              IO_we<='0';
--            end if;
--          end if;
      end case;
    end if;
  end process;

  bram_info:process(inst_addr,inst_in,inst_we,inst_out)
  begin
    if rising_edge(clk) then
		report core_state_type'image(core_state);
     report "BRAM addr:" & integer'image(CONV_INTEGER(inst_addr)) & " WE:" & integer'image(conv_integer(inst_we)) &
				"data_in:" & integer'image(conv_integer(inst_in)) &
				"data_out:" & integer'image(conv_integer(inst_out));
				end if;
  end process;
end RTL;
