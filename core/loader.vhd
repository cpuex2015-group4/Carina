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
    addr:out BRAM_ADDRT;
    din:out datat;
    bram_we:out std_logic_vector(0 downto 0);
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
    case (state) is
      when HEADER=>
        if IO_empty='0' then
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

          if i<4 then
            i<=i+1;
          else
            i<=0;
            state<=TEXT_RECEIVING;
			end if;
        else
          IO_RE<='0';
        end if;
    when TEXT_RECEIVING=>
            bram_we<="1";    
       if i<conv_integer(text_size) then
         if IO_empty='0' then
           addr<=CONV_STD_LOGIC_VECTOR(i,14);
           din<=IO_recv_data;
           io_re<='1';
           i<=i+1;
         else
           io_re<='0';
         end if;
       else
         io_re<='0';
         state<=DATA_RECEIVING;
         i<=conv_integer(data_offset);
       end if;
    when DATA_RECEIVING =>
      if i<conv_integer(data_offset+data_size) then
        if IO_empty='0' then
          addr<=CONV_STD_LOGIC_VECTOR(i,14);
          din<=IO_recv_data;
          io_re<='1';
          i<=i+1;
        else
          io_re<='0';
        end if;
      else
        io_re<='0';
        state<=FINISHED;
      end if;
    when FINISHED=>
            bram_we<="0";
      io_re<='0';
      loaded<='1';
  end case;
  end process;
end kaisensionoodle;

