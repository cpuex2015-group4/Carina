library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library UNISIM;
use UNISIM.VComponents.all;

library work;
use work.p_type.all;

entity io_module_top is
port (
  MCLK1 : in    std_logic;
  RS_RX : in    std_logic;
  RS_TX : out   std_logic;
  ZD    : inout std_logic_vector(31 downto 0);
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
end io_module_top;

architecture RTL of io_module_top is

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


--clk
  signal iclk:std_logic:='0';
  signal clk:std_logic:='0';
  
--IO
  signal IO_full,IO_WE,IO_RE:std_logic:='0';
  signal IO_empty:std_logic:='1';
  signal IO_recv_data,IO_send_data:std_logic_vector(7 downto 0):=x"00";
	signal io_serial_send,io_serial_recv:std_logic;
--core
	signal DEBUG_inner:top_debug_out;
	

	type statet is (idle,re_on,data_waiting,fetch,switch_we_on,switch_we_off);
	signal state:statet:=idle;
 

--debug
	signal IO_ing:boolean:=false;
begin
  RS_TX<=io_serial_send;
  io_serial_recv<=RS_RX;
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
  
  iomod:io_module port map(
    clk,io_WE,io_RE,
    io_send_data,
    io_recv_data,
    io_full,io_empty,
    io_serial_send,
    io_serial_recv
    );
  

loopback:process(clk)
	begin
		if rising_edge(clk) then
			case (state) is
				when idle=>
					if io_empty='0' then
						io_re<='1';
						state<=re_on;
					end if;
				when re_on=>
					io_re<='0';
					state<=data_waiting;
				when data_waiting=>
					state<=fetch;
				when fetch=>
					io_send_data<=io_recv_data;
					state<=switch_we_on;
				when switch_we_on=>
					if io_full='0' then
						io_we<='1';
						state<=switch_we_off;
					end if;
				when switch_we_off=>
					io_we<='0';
					state<=idle;
			end case;
		end if;
	end process;  
end RTL;
