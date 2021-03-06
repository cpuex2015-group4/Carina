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
  DEBUG :out top_debug_out
);
end cpu;



----pohepohe architecture
----pipeline mo nanimo sitenai yo
----pipeline ga sitai naa



architecture RTL of cpu is

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
      IO_RE,loaded: out std_logic:='0'
    );            
  end component;


  constant ZERO:datat:=x"00000000";
--zentaiseigyo kei
 
  signal PC :datat:=ZERO;
  signal reg_file:reg_filet:=(others=>ZERO);
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

--signal operand1:datat;-
--signal operand2:datat;
--signal alu_control:alu_controlt;
--signal shamt:regt;
signal result:datat;
--signal isZero:std_logic;


 --loader
      signal loader_activate: std_logic:='0';
      signal loader_addr: BRAM_ADDRT;
      signal loader_din: datat;
      signal loader_IO_RE,loaded: std_logic:='0';
	
 
  
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
    isZero=>control.isZero);

  lod:loader port map(
    clk=>clk,
	 IO_empty=>IO_empty,
	 activate=>loader_activate,
	 IO_RECV_DATA=>IO_recv_data,
	 addr=>loader_addr,
	 din=>inst_in,
	 bram_we=>inst_we,
	 io_re=>loader_io_re,
	 loaded=>loaded);
      
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
      if io_full='0' then
        io_we<='1';
        io_send_data<=x"4341524e";
      else
        io_we<='0';
        core_state<=WaIT_HEADER;
      end if;
    when WAIT_HEADER =>
      --debug
      DEBUG.data1<=inst_out;
      DEBUG.core_state<=core_state;
      DEBUG.PC<=CONV_STD_LOGIC_VECTOR(count,32);
      DEBUG.control<=control;
      --/debug
      loader_activate<='1';
      if loaded='1' then
			io_send_data<=x"52435644";
			IO_WE<='1';
        core_state<=EXE_READY;
      else
        io_send_data<=io_recv_data;
        io_we<=loader_io_re;
      end if;
    when EXE_READY=>
			io_we<='0';
      report "exe ready";
      core_state<=EXECUTING;    --data source no kirikae
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
  DEBUG.data3<=reg_file(3);
  DEBUG.alucont<=alu_control;
  --/debug
      
      case ( exe_state) is
        when F =>
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
			 
          controlv:=make_control(instv.opecode,instv.funct);
          if controlv.RegDst='0' then
            instv.reg_dest:=instv.rd;
          else
            instv.reg_dest:=instv.rt;
          end if;
          inst<=instv;
          data.operand1<=reg_file(CONV_INTEGER(instv.rs));
          if controlv.ALUSrc='0' then
            data.operand2<=reg_file(CONV_INTEGER(instv.rt));
          else
            data.operand2<="0000000000000000" & instv.immediate;
          end if;
          control<=controlv;
        when EX =>
          exe_state<=MEM;

--          operand1<=data.operand1;
--          operand2<=data.operand2;
--          alu_control<=make_alu_control(inst.opecode,inst.funct);
--          shamt<=inst.shamt;
          data.result<=result;

          case (control.PC_control) is
            when normal =>
              data.newPC<=PC+1;
            when b=>
              if inst.immediate(15)='0' then
                data.newPC<=PC+1+("0000000000000000" + inst.immediate);
              else
                data.newPC<=PC+1+("1111111111111111" + inst.immediate);
              end if;
            when j=>
              data.newPC<="0000000000000000"&inst.immediate;
            when jr =>
              data.newPC<=reg_file(CONV_INTEGER(inst.rs));
          end case;
        when MEM =>
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
          else
			    exe_state<=WB;
			 end if;
        when WB =>
          IO_re_cpu<='0';
         IO_we<='0';
          
           if control.RegWrite='1' then
             if inst.reg_dest /= x"00000" then
               reg_file(CONV_INTEGER(inst.reg_dest))<=data.result;
             end if;
           end if;
          exe_state<=F;
           if inst.opecode=x"03" then  --jump and link
             reg_file(31)<=PC+x"00000001";
           end if;
           case (control.PC_control) is
             when normal =>
               vPC:=PC+x"00000001";
             when j| jr =>
               vPC:=data.newPC;
             when b =>
               if (inst.opecode="000100" and control.isZero='1') or
                  (inst.opecode="000101" and control.isZero='0') then
                 vPC:=data.newPC;
               else
                 vPC:=PC+x"00000001";
               end if;
           end case;
           PC<=vPC;
      end case;
    when HALTED =>
      -- do nothing;
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
