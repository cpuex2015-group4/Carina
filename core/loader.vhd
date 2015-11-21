library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

library work;
use work.p_type.all;

entity loader is
  port (
    clk,IO_empty,activate: in std_logic;
    IO_recv_data: in std_logic_vector(31 downto 0);
    addr:out BRAM_ADDRT:="000000000000000";
    din:out datat:=x"00000000";
    bram_we:out std_logic_vector(0 downto 0):="0";
    SRAM_ADDR:out std_logic_vector(19 downto 0):="00000000000000000000";
    SRAM_DATA:inout datat:="ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
    SRAM_WE:out std_logic:='1';
    entry:out datat;
    IO_RE,loaded: out std_logic:='0';
    heap_head:out datat:=x"00000000";
    reset:in std_logic:='0'
    );
end loader;

architecture kaisensionoodle of loader is
  type statet is (HEADER,TEXT_RECEIVING,DATA_RECEIVING,FINISHED);
  signal state:statet:=HEADER;
  signal text_size:datat;
  signal data_offset:datat;
  signal data_size:datat;
  signal entry_point:datat;
  signal i:datat:=x"00000000";
  signal justread:boolean:=false;
  signal recvdata:datat:=x"00000000";

  constant sram_wait:std_logic_vector(2 downto 0):="010";
  signal sram_count:std_logic_vector(2 downto 0):="000";
begin
  heap_head<=text_size+data_size;
  data_offset<=text_size;
  entry<=entry_point;
  main:process(clk)
  begin
    if rising_edge(clk) then
      if reset='1' then
        bram_we<="0";
        IO_RE<='0';
        loaded<='0';
        i<=x"00000000";
        state<=header;
        justread<=false;
      else
        case (state) is
          when HEADER=>
--		 report "head";
            if i<4 then
              if justread then
                IO_RE<='0';
                i<=i+x"00000001";
                justread<=false;
              else
                if IO_empty='0' then
                  IO_RE<='1';
                  case (i) is
                    when x"00000001" =>
                      text_size<=IO_recv_data;
                    when x"00000002" =>
                      data_size<=IO_recv_data;
                    when x"00000003" =>
                      entry_point<=IO_recv_data;
                    when others =>
                  --assert false
                  --   report "crazy i in loader_HEADER:" & integer'image(i);
                  end case;
                  justread<=true;
                end if;
              end if;
            else
              i<=x"00000000";
              state<=TEXT_RECEIVING;
            end if;
          when TEXT_RECEIVING=>
            if i<conv_integer(text_size) then
              if justread then
                io_re<='0';
                justread<=false;
                i<=i+x"00000001";
                BRAM_WE<="0";
              else
                if IO_empty='0' then
                  din<=IO_recv_data;
                  addr<=i(BRAM_ADDR_SIZE-1 downto 0);
                  justread<=true;
                  BRAM_WE<="1";
                  io_re<='1';
                end if;
              end if;
            else
              state<=DATA_RECEIVING;
              i<=data_offset;
            end if;
          when DATA_RECEIVING =>
            if i<conv_integer(data_offset+data_size) then
              if justread then
                io_re<='0';
                case (sram_count) is
                  when "000" =>
                    SRAM_ADDR<=i(19 downto 0);
                    SRAM_WE<='0';
                    sram_count<=sram_count+"001";
                    sram_data<="ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
                  when sram_wait =>
                    sram_we<='1';
                    sram_count<="000";
                    sram_data<=recvdata;
                    justread<=false;
                    i<=i+x"00000001";
                  when others=>
                    SRAM_WE<='1';
                    SRAM_DATA<="ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
                    sram_count<=sram_count+"001";
                end case;
              else
                if IO_empty='0' then
                  recvdata<=IO_recv_data;
                  io_re<='1';
                  justread<=true;
                end if;
              end if;
            else
              state<=FINISHED;
            end if;
          when FINISHED=>
            loaded<='1';
        end case;
      end if;
    end if;
  end process;
  
  debug:process(state)
  begin
  --report "state:" & statet'image(state);
  end process;
--  debueg:process(i)
--  begin
--	if i'event then-
--	  report "i=" & integer'image(i);
--   end if;
--  end process;
end kaisensionoodle;

