library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity receiver_wrapper is
  generic(
    half_section:std_logic_vector(15 downto 0):=x"0D8B"
  );
  port(
    clk,serial_in:      in      std_logic;
    read_enable:        in      std_logic;
    empty:              out     std_logic;
    output:             out     std_logic_vector(7 downto 0):=x"00"
    );
end receiver_wrapper;

architecture RTL of receiver_wrapper is
  component receiver
    generic (
		half_section:std_logic_vector(15 downto 0):=half_section
    );
    port(
      clk,input: in std_logic;
      valid : out       std_logic;
      data  : out       std_logic_vector(7 downto 0)
    );
  end component;
  component fifo8
    port(
      clk     : in    std_logic;
      wr_en   : in    std_logic;
      rd_en   : in    std_logic;
      din     : in    std_logic_vector( 7 downto 0);
      dout    : out   std_logic_vector( 7 downto 0);
      full    : out   std_logic;
      empty   : out   std_logic
    );
  end component;
  signal wr_en,full:std_logic:='0';
  signal din:std_logic_vector(7 downto 0);
  signal valid:std_logic:='0';
  signal has_fifoed:std_logic:='1';
  signal recv_data:std_logic_vector(7 downto 0);
  signal out_inner:std_logic_vector(7 downto 0);
begin
  obuf:fifo8 port map(clk,wr_en,read_enable,din,out_inner,full,empty);
  RCVR:receiver port map(clk,serial_in,valid,din);
  output<=out_inner;

  process(clk)
  begin
    if rising_edge(clk) then
      if valid='0' then
        has_fifoed<='0';
      else
       if has_fifoed='0' then
         wr_en<='1'; 
         has_fifoed<='1';
       else --already put in fifo
         wr_en<='0';
       end if;--has_fifoed or not
     end if; --valid or not
    end if;--rising edge
  end process;
end RTL;
