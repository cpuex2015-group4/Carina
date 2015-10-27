library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library UNISIM;
use UNISIM.VComponents.all;
 

entity top is
  port (
    MCLK1 : in    std_logic;
    RS_RX : in   std_logic;
    RS_TX : out   std_logic
  );
end top;

architecture RTL of top is
  component   entity IO32 is
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
 ST_IDLE:std_logic_vector(1 downto 0):="00";
  constant ST_RECEIVING:std_logic_vector(1 downto 0):="01";
  constant ST_SENDING:std_logic_vector(1 downto 0):="11";
  signal rs_rx_latch:std_logic:='1';
  signal state:std_logic_vector(1 downto 0):=ST_IDLE;
  signal iclk,clk:std_logic;
  signal go,busy,valid:std_logic:='0';
  signal sender_data,receiver_data,data:std_logic_vector(7 downto 0);


  signal TEST_DATA:std_logic_vector(7 downto 0):=X"88";
  signal counter:std_logic_vector(7 downto 0):=x"00";
begin
  rs_rx_latch<=RS_RX;
  ib:   IBUFG port map(
    i=>MCLK1,
    o=>iclk
  );
  bg: BUFG port map(
    i=>iclk,
    o=>clk
  );

  SNDR:sender port map(clk,go,sender_data,RS_TX,busy);
  RCVR:receiver port map(clk,rs_rx_latch,valid,receiver_data);

  receiving:process(clk)
  begin
    if rising_edge(clk) then
    end if;
  end process;
end RTL;
