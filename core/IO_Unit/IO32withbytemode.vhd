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
    recv_data:out               std_logic_vector(31 downto 0):=x"DEADDADA";
    full:out              std_logic:='0';
	     empty:out              std_logic:='1';
    serial_send:out             std_logic;
    serial_recv:in              std_logic;
    word_access:in              std_logic
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

  signal recv_buffer:std_logic_vector(7 downto 0);
  signal received:boolean:=false;
  signal inner_re:std_logic:='0';
  signal inner_empty:std_logic:='1';
  constant re_count_max:std_logic_vector(2 downto 0):="001";
  signal re_count:std_logic_vector(2 downto 0):="000";
begin
  io:io_module port map (clk,we,inner_re,send_data(7 downto 0),recv_buffer,full,inner_empty,serial_send,serial_recv);

  main :process(clk)
  begin
    if rising_edge(clk) then
      if received then
        if re='1' then
          empty<='1';
          recv_buffer<=x"F1";
        end if;
      else
        case re_count is
          when "000" =>
            if inner_empty='0' then
              inner_re<='1';
              re_count<=re_count+"001";
            end if;
          when re_count_max =>
            inner_re<='0';
            re_count<="000";
            recv_data<=x"000000" & recv_buffer;
            empty<='0';
          when others =>
            inner_re<='0';
            re_count<=re_count+"001";
        end case;
      end if;
    end if;
  end process;
  
end pohe;
 
