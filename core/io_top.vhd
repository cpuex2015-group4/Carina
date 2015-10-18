library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library UNISIM;
use UNISIM.VComponents.all;

library work;
use work.p_type.all;

entity io_top is
port (
  MCLK1 : in    std_logic;
  RS_RX : in    std_logic;
  RS_TX : out   std_logic;
  ZD    : inout std_logic_vector(31 downto 0):=x"00000000";
  ZA    : out   std_logic_vector(19 downto 0);
  XWA   : out   std_logic;
  XE1   : out   std_logic;
  E2A   : out   std_logic;
  XE3   : out   std_logic;
  XGA   : out   std_logic;
  XZCKE : out   std_logic;
  ADVA  : out   std_logic;
  XLBO  : out   std_logic;
  ZZA   : out   std_logic;
  XFT   : out   std_logic;
  XZBE  : out   std_logic_vector(3 downto 0);
  ZCLKMA : out std_logic_vector(1 downto 0)
--  DEBUG :out top_debug_out
);
end io_top;

architecture RTL of IO_top is

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


  
  constant WAIT_CLK:integer:=100;
  signal WAIT_COUNT:integer:=0;
  
--clk
  signal iclk:std_logic:='0';
  signal clk:std_logic:='0';
  
--IO
  signal IO_empty,IO_full,IO_WE,IO_RE:std_logic:='0';
  signal IO_recv_data,IO_send_data:std_logic_vector(7 downto 0):=x"00";

--core
	signal DEBUG_inner:top_debug_out;



--debug

begin
  ZA    <="00000000000000000000";
  XWA  <='0';
  XE1   <='0';
  E2A   <='0';
  XE3   <='0';
  XGA   <='0';
  XZCKE <='0';
  ADVA  <='0';
  XLBO  <='0';
  ZZA   <='0';
  XFT   <='0';
  XZBE  <="0000";
  ZCLKMA <=clk & clk;
  --DEBUG<=DEBUG_inner;
  ib: IBUFG port map(
    i=>MCLK1,
    o=>iclk
  );
  bg:  BUFG port map(
    i=>iclk,
    o=>clk
  );
  io: IO_module port map(clk,IO_WE,IO_RE,IO_send_data,IO_recv_data,IO_full,IO_empty, RS_TX,RS_RX);

	iodebug:process(clk)
	begin
	  if rising_edge(clk) then
            if WAIT_COUNT<WAIT_CLK then
              WAIT_COUNT<=WAIT_COUNT+1;
            else
              if io_full='0' and io_empty='0' then
                io_we<='1';
                io_re<='1';
                io_send_data<=io_recv_data;
              else
                io_we<='0';
                io_re<='0';
              end if;
            end if;
	  end if;
	end process;

--  core:CPU port map(clk,IO_empty,IO_full,IO_recv_data,IO_WE,IO_RE,IO_send_data,DEBUG_inner);
end RTL;
