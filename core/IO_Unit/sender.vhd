library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity sender is
  generic (
    half_section : std_logic_vector(15 downto 0) :=x"0D8B"
  );
  port(
    clk,go      : in    std_logic;
    data_in     : in    std_logic_vector(7 downto 0);
    output,busy : out   std_logic
  );
end sender;

architecture RTL of sender is
  constant SECTION      :std_logic_vector(15 downto 0):=half_section+half_section;
  constant ST_IDLE      :std_logic_vector(3 downto 0):="0000";
  constant ST_START     :std_logic_vector(3 downto 0):="0001";
  constant ST_SEND0     :std_logic_vector(3 downto 0):="0010";
  constant ST_SEND1     :std_logic_vector(3 downto 0):="0011";
  constant ST_SEND2     :std_logic_vector(3 downto 0):="0100";
  constant ST_SEND3     :std_logic_vector(3 downto 0):="0101";
  constant ST_SEND4     :std_logic_vector(3 downto 0):="0110";
  constant ST_SEND5     :std_logic_vector(3 downto 0):="0111";
  constant ST_SEND6     :std_logic_vector(3 downto 0):="1000";
  constant ST_SEND7     :std_logic_vector(3 downto 0):="1001";
  constant ST_STOP      :std_logic_vector(3 downto 0):="1010";
  
  signal data   : std_logic_vector(7 downto 0);
  signal state  : std_logic_vector(3 downto 0):=ST_IDLE;
  signal counter: std_logic_vector(15 downto 0):=x"0000";
  signal busy_inner:std_logic:='0';
begin
  busy<=busy_inner;
  main:process(clk)
  begin
    if rising_edge(clk) then
      if    state=ST_IDLE  then
        data<=data_in;
        output<='1';
      elsif state=ST_START then
        output<='0';
      elsif state=ST_SEND0 then
        output<=data(0);
      elsif state=ST_SEND1 then
        output<=data(1);
      elsif state=ST_SEND2 then
        output<=data(2);
      elsif state=ST_SEND3 then
        output<=data(3);
      elsif state=ST_SEND4 then
        output<=data(4);
      elsif state=ST_SEND5 then
        output<=data(5);
      elsif state=ST_SEND6 then
        output<=data(6);
      elsif state=ST_SEND7 then
        output<=data(7);
      elsif state=ST_STOP  then
        output<='1';
--      else     --illegal
      end if;
    end if;
  end process;

  state_move:process(clk)
  begin
    if rising_edge(clk) then
        if state=ST_IDLE then
          if go='1' then
            state<=ST_START;
            counter<="0000000000000000";
            busy_inner<='1';
           end if;
        elsif counter=SECTION then
          counter<="0000000000000000";
          if state=ST_STOP then
            state<=ST_IDLE;
            busy_inner<='0';
          else
            state<=state+"0001";
          end if;
        else
          counter<=counter+"0000000000000001";
        end if;
    end if;--rising_edge
  end process;
end RTL;
