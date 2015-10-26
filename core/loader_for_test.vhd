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
  signal i:datat:=x"00000000";
  signal justread:boolean:=false;
begin
  main:process(clk)
  begin
   if rising_edge(clk) then
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
                  data_offset<=IO_recv_data;
                when x"00000003" =>
                  data_size<=IO_recv_data;
                when others =>
                  --assert false
                 --   report "crazy i in loader_HEADER:" & integer'image(i);
              end case;
              justread<=true;
            end if;
          end if;
        else
          report "i,tsize,doft,dsize=" & integer'image (conv_integer(i)) & ","& integer'image(conv_integer(text_size)) & ","  &
            integer'image(conv_integer(data_offset)) & "," & integer'image(conv_integer(data_size));
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
              report "text_recv:i,tsize,doft,dsize=" & integer'image (conv_integer(i)) & ","& integer'image(conv_integer(text_size)) & ","  &
              integer'image(conv_integer(data_offset)) & "," & integer'image(conv_integer(data_size));
              report "write_inst@" & integer'image(conv_integer(i)) & ":" & integer'image(conv_integer(io_recv_data));
              din<=IO_recv_data;
              addr<=i(13 downto 0);
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
            BRAM_WE<="0";
            io_re<='0';
            i<=i+x"00000001";
            justread<=false;
          else
            if IO_empty='0' then
              report "data_receiving@" & integer'image(conv_integer(i)) & ":" & integer'IMAGE(conv_integer(io_recv_data)) ;     
              addr<=i(13 downto 0);
              din<=IO_recv_data;
              io_re<='1';
				  justread<=true;
				  bram_we<="1";
            end if;
          end if;
        else
          state<=FINISHED;
        end if;
      when FINISHED=>
        loaded<='1';
    end case;
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

