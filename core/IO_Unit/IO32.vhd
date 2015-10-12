--This is a wrapper of IO_unit
--IO_unit allows us to IOing with 8-bit data.
--This will buffer them and provides the 32-bit IO-ing interface.

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity IO32 is
  port(
    clk,WE,RE:in                std_logic;
    send_data:in                std_logic_vector(31 downto 0);
    recv_data:out               std_logic_vector(31 downto 0);
    full,empty:out              std_logic;
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
      full,empty:out              std_logic;
      serial_send:out             std_logic;
      serial_recv:in              std_logic
      );
  end component;
  signal clk,io_WE,io_RE:in                std_logic;
  signal io_send_data:in                std_logic_vector(7 downto 0);
  signal io_recv_data:out               std_logic_vector(7 downto 0);
  signal io_full,io_empty:out              std_logic;
 
  signal rcv_processed:std_logic:='0';
  signal snd_processing:std_logic:='0';
  signal reading:std_logic:='0';
  signal send_count:integer:=0;
  signal recv_count:integer:=0;
  signal send_buf,recv_buf:std_logic_vector(31 downto 0);
begin
  io:io32 port map (clk,io_we,io_re,io_send_data,io_recv_data,io_full,io_empty,serial_send,serial_recv);

  full<=io_full or snd_processing; 
  
  main :process(clk)
  begin
    if rising_edge(clk) then
      if snd_processing='1' then
        if send_count<=3 then
          if io_full='0' then
            io_we<='1';
            io_send_data<=send_buf((send_count+1)*8-1 downto send_count*8);
            send_count<=send_count+1;
          else
            io_we<='0';
          end if;
        else
          io_we<='0';
          snd_processing<='0';
        end if;
      else
        if we<='1' then
          assert full='0'
            report "write when full";
          send_buf<=send_data;
          send_count<=0;
          snd_processing<='1';
        end if;
      end if;

      if rcv_processed='0' then
        if recv_count<=3 then
          if io_empty='0' then
            if reading='0' then
              io_re<='1';
              reading<='1';
            else
              recv_buf((recv_count+1)*8-1 downto recv_count*8)<=io_recv_data;
              io_re<='0';
              recv_count<=recv_count+1;
            end if;
          end if;
        else
          recv_data<=recv_buf;
          rcv_processed='1';
          empty<='0';
        end if;
      else
        if re<='1' then
          recv_count<=0;
          rcv_processed<='0';
          empty<='1';
        end if;
      end if;
    end if;
  end process;
end pohe;
