--This is a wrapper of IO_unit
--IO_unit allows us to IOing with 8-bit data.
--This will buffer them and provides the 32-bit IO-ing interface.

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
entity IO32 is
  port(
    clk,WE,RE:in                std_logic;
    send_data:in                std_logic_vector(31 downto 0);
    recv_data:out               std_logic_vector(31 downto 0);
    full:out              std_logic:='0';
	     empty:out              std_logic:='1';
    serial_send:out             std_logic;
    serial_recv:in              std_logic;
    word_access:in              std_logic    --this is ignored now. always
                                             --32bit access mode
    );

end IO32;

architecture pohe of IO32 is
  component IO_module
    port(
      clk,WE,RE:in                std_logic;
      send_data:in                std_logic_vector(7 downto 0);
      recv_data:out               std_logic_vector(7 downto 0);
      full: out 						 std_logic:='1';
		empty:out                   std_logic:='1';
      serial_send:out             std_logic;
      serial_recv:in              std_logic
      );
  end component;
  signal io_WE,io_RE:                std_logic:='0';
  signal io_send_data:                std_logic_vector(7 downto 0);
  signal io_recv_data:               std_logic_vector(7 downto 0):=x"ff";
  signal io_full,io_empty:              std_logic:='0';
 
  signal rcv_processed:std_logic:='0';
  signal snd_processing:std_logic:='0';
  signal fifo_read_wait:integer:=0;
  signal send_count:integer:=0;
  signal recv_count:integer:=0;
  signal send_buf,recv_buf:std_logic_vector(31 downto 0):=x"ffffffff";
begin
  io:io_module port map (clk,io_we,io_re,io_send_data,io_recv_data,io_full,io_empty,serial_send,serial_recv);
 
  main :process(clk)
  begin
    if rising_edge(clk) then
      if snd_processing='1' then
			--assert false
			--  report integer'image(send_count);
        if send_count<=3 then
          if io_full='0' then
			--   report "sc:" & integer'image(send_count);
				
            io_we<='1';
            case (send_count) is
              when 0 =>
                io_send_data<=send_buf(31 downto 24);
              when 1 =>
                io_send_data<=send_buf(23 downto 16);
              when 2 =>
                io_send_data<=send_buf(15 downto 8);
              when 3 =>
                io_send_data<=send_buf(7 downto 0);
              when others=> --impossible case
                io_send_data<=x"00";
            end case;
            send_count<=send_count+1;
          else
            io_we<='0';
          end if;
        else
          io_we<='0';
          snd_processing<='0';
          full<='0';
        end if;
      else  --snd_processing=0
        if we='1' then
          send_buf<=send_data;
          send_count<=0;
          snd_processing<='1';
          full<='1';
        end if;
      end if;

       if rcv_processed='0' then
        if recv_count<=3 then
            if fifo_read_wait=0 then
              if io_empty='0' then
                io_re<='1';
                fifo_read_wait<=1;
              end if;
            elsif fifo_read_wait=1 then
              fifo_read_wait<=2;
            else
              report  ":read a byte here:" & integer'image(recv_count) & " " & integer'image(conv_integer(io_recv_data));
              case (recv_count) is
              when 0 =>
               recv_buf(31 downto 24)<=io_recv_data;
              when 1 =>
                recv_buf(23 downto 16)<=io_recv_data;
              when 2 =>
                recv_buf(15 downto 8)<=io_recv_data;
              when 3 =>
                recv_buf(7 downto 0)<=io_recv_data;
              when others=> --impossible case
                --do nothing
            end case;
              io_re<='0';
              recv_count<=recv_count+1;
              fifo_read_wait<=0;
            end if;
        else
          recv_data<=recv_buf;
          rcv_processed<='1';
          empty<='0';
        end if;
      else
        if re='1' then
          recv_count<=0;
          rcv_processed<='0';
          empty<='1';
        end if;
      end if;
    end if;
  end process;
  
  debug:process(io_recv_data,re)
  begin
		if rising_edge(re) then
			report "iore:" & integer'image (conv_integer(io_recv_data));
		end if;
  end process;
end pohe;
 
