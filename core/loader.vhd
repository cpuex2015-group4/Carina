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
    addr:out BRAM_ADDRT:="00000000000000";
    din:out datat:=x"00000000";
    bram_we:out std_logic_vector(0 downto 0):="0";
    IO_RE,loaded: out std_logic:='0'
  );
end loader;

architecture kaisensionoodle of loader is
  type statet is (HEADER,TEXT_RECEIVING,DATA_RECEIVING,FINISHED);
  signal state:statet:=HEADER;
  signal text_size:datat;
  signal data_offset:datat;
  signal data_size:datat;
  signal i:integer:=0;
begin
  main:process(clk)
  begin
   if rising_edge(clk) then
    case (state) is
      when HEADER=>
        if i<4 then
          if IO_empty='0' then
 --            report "loader:phaze" & integer'image(i) & ":data=" & integer'(conv_integer(IO_recv_data)); 
            i<=i+1;
            IO_RE<='1';
            case (i) is
              when 1 =>
                text_size<=IO_recv_data;
              when 2 =>
                data_offset<=IO_recv_data;
              when 3 =>
                data_size<=IO_recv_data;
              when others =>
                assert false
                  report "crazy i in loader_HEADER";
            end case;
          else
            IO_RE<='0';
          end if;
        else
          report "i,tsize,doft,dsize=" & integer'image (i) & ","& integer'image(conv_integer(text_size)) & ","  &
            integer'image(conv_integer(data_offset)) & "," & integer'image(conv_integer(data_size));
          i<=0;
          state<=TEXT_RECEIVING;
          IO_RE<='0';
        end if;
      when TEXT_RECEIVING=>
        if i<conv_integer(text_size) then
          if IO_empty='0' then
            report "write_inst@" & integer'image(i) & ":" & integer'image(conv_integer(io_recv_data));
            din<=IO_recv_data;
            addr<=CONV_STD_LOGIC_VECTOR(i,14);
            io_re<='1';
            i<=i+1;
            BRAM_WE<="1";
          else
            BRAM_we<="0";
            io_re<='0';
          end if;
        else
          BRAM_we<="0";
          io_re<='0';
          state<=DATA_RECEIVING;
          i<=conv_integer(data_offset);
        end if;
      when DATA_RECEIVING =>
        report "data_receiving:" & integer'image(i);
        if i<conv_integer(data_offset+data_size) then
          if IO_empty='0' then
            addr<=CONV_STD_LOGIC_VECTOR(i,14);
            din<=IO_recv_data;
            io_re<='1';
            BRAM_WE<="1";
            i<=i+1;
          else
            io_re<='0';
            bRAM_we<="0";
          end if;
        else
          io_re<='0';
			 BRAM_WE<="0";
          state<=FINISHED;
        end if;
      when FINISHED=>
        bram_we<="0";
        io_re<='0';
        loaded<='1';
    end case;
   end if;
  end process;
  
  debug:process(state)
  begin
--	report "state:" & statet'image(state);
  end process;
end kaisensionoodle;

