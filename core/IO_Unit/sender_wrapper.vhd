library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity sender_wrapper is
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
end sender_wrapper;

architecture RTL of sender_wrapper is
  component sender
    generic (
      half_section:std_logic_vector(15 downto 0):=half_section
    );
    port(
      clk,go      : in           std_logic;
      data_in     : in           std_logic_vector(7 downto 0);
      output,busy : out          std_logic
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
  signal rd_en,go,busy:std_logic:='0';
  signal empty:std_logic:='1';
  signal dout:std_logic_vector( 7 downto 0);

  signal entry_prohibiting:std_logic:='0';
begin
  sbuf:fifo8 port map(clk,write_enable,rd_en,input,dout,full,empty);
  SNDR:sender port map(clk,go,dout,serial_out,busy);
  process(clk)
  begin
    if rising_edge(clk) then
      if busy='0' and empty ='0' and entry_prohibiting='0' then
        rd_en<='1';
        entry_prohibiting<='1';
      end if;
      if rd_en='1' then
        rd_en<='0';
        go<='1';
      end if;
      if go='1' then
        go<='0';
      end if;
      if go='0' and rd_en='0' and entry_prohibiting='1' then
        entry_prohibiting<='0';
      end if;
    end if;
  end process;

debug:process(clk)
begin
  if rising_edge(clk) then
  if write_enable='1' then
--    report "write:" & integer'image(conv_integer(input));
  end if;
  end if;
end process;  
end RTL;
