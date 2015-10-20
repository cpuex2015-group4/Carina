library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity IO_module is
  port(
    clk,WE,RE:in                std_logic;
    send_data:in                std_logic_vector(7 downto 0);
    recv_data:out               std_logic_vector(7 downto 0);
    full,empty:out              std_logic;
    serial_send:out             std_logic;
    serial_recv:in              std_logic
    );
end IO_module;

architecture RTL of IO_module is
  component sender_wrapper
    generic(
      half_section:std_logic_vector(15 downto 0):=x"0D8B"
    );
    port(
      clk:                 in     std_logic;
      input:               in     std_logic_vector(7 downto 0);
      write_enable:        in     std_logic;
      full:                out    std_logic;
      serial_out:          out    std_logic
    );
  end component;

  component receiver_wrapper
    generic(
      half_section:std_logic_vector(15 downto 0):=x"0D8B"
      );
    port(
      clk,serial_in:      in      std_logic;
      read_enable:        in      std_logic;
      empty:              out     std_logic;
      output:             out     std_logic_vector(7 downto 0):=x"00"
      );
  end component;
  signal dummy:std_logic_vector(7 downto 0);
  signal serial_recv_buffer:std_logic;
begin
  serial_recv_buffer<=serial_recv;
  dummy<=send_data;
  SND:sender_wrapper port map (clk,dummy,WE,full,serial_send);
  RCV:receiver_wrapper port map(clk,serial_recv_buffer,RE,empty,recv_data);

end RTL;
