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
    full:out                    std_logic:='0';
    empty:out                   std_logic:='1';
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
      full: out                   std_logic;
      empty:out                   std_logic;
      serial_send:out             std_logic;
      serial_recv:in              std_logic
      );
  end component;
  signal io_WE,io_RE:             std_logic:='0';
  signal io_send_data:            std_logic_vector(7 downto 0):=x"ff";
  signal io_recv_data:            std_logic_vector(7 downto 0):=x"ff";
  signal io_full:                 std_logic:='0';
  signal io_empty:                std_logic:='1';
  signal snd_processing:std_logic:='0';
  signal send_count:integer:=0;
  signal send_buf:std_logic_vector(31 downto 0):=x"ffffffff";

--reading:
  constant READ_wait:integer:=3;
  signal data_ready:boolean:=false;
  signal read_wait_i:integer:=0;
  signal read_bytes:integer:=0;
  signal recv_buf:std_logic_vector(31 downto 0);
begin
  io:io_module port map (clk,io_we,io_re,io_send_data,io_recv_data,io_full,io_empty,serial_send,serial_recv);

  full<= snd_processing; 
  main :process(clk)
  begin
    if rising_edge(clk) then
      if snd_processing='1' then
        --assert false
        --report integer'image(send_count);
        if send_count<=3 then
          if io_full='0' then
            --report "sc:" & integer'image(send_count);
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
        end if;
      else--snd_processing=0
        if we='1' then
          send_buf<=send_data;
          send_count<=0;
          snd_processing<='1';
        end if;
      end if;

      if data_ready then
        if RE<='1' then
          data_ready<=false;
          read_wait_i<=0;
          read_bytes<=0;
          empty<='1';
        end if;
      else--data_ready
        if read_bytes<=2 then
          if read_wait_i=0 then
            if io_empty='0' then
              io_re<='1';
              read_wait_i<=1;
            end if;
          else
            io_re<='0';
            if read_wait_i<=read_wait then
              read_wait_i<=read_wait_i+1;
            else
              case (read_bytes) is
                when 0 =>
                  recv_buf(31 downto 24)<=io_recv_data;
                when 1 =>
                  recv_buf(23 downto 16)<=io_recv_data;
                when 2 =>
                  recv_buf(15 downto 8)<=io_recv_data;
                when 3 =>
                  --recv_buf(7 downto 0)<=io_recv_data;
                  recv_data(31 downto 8)<=recv_buf(31 downto 8);
                  recv_data(7 downto 0)<=io_recv_data;
                when others =>
                  report "impossible read_bytes in io32_recv";
              end case;

              if read_bytes<=2 then
                read_bytes<=read_bytes+1;
                read_wait_i<=0;--kokode wait until !io_empty ni modoru
              else
                data_ready<=true;
            end if;
          end if;
            
      end if;--data ready
  end process;
  debug:process(io_recv_data,re)
  begin
    if rising_edge(re) then
      report "iore:" & integer'image (conv_integer(io_recv_data));
    end if;
  end process;
end pohe;
 
