library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;


entity receiver is
  generic (
    half_section : std_logic_vector(15 downto 0) :=x"0D8B"
  );
  port(
    clk,input: in   std_logic;
    valid   : out   std_logic;
    data    : out   std_logic_vector(7 downto 0):="00000000"
  );
end receiver;

architecture RTL of receiver is
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

  signal state: std_logic_vector(3 downto 0):=ST_IDLE;
  signal counter: std_logic_vector(15 downto 0):="0000000000000000";
  signal working:std_logic:='0';
  signal data_inner:std_logic_vector(7 downto 0);
  
begin
  valid<=not working;
  main:process(clk)
  begin
    if rising_edge(clk) then
      if state=ST_IDLE  then
        if input='0' then
          working<='1';
          data<=data_inner;
        else
          working<='0';
        end if;
      elsif state=ST_START then
        working<='1';
      elsif state=ST_SEND0 then
        if counter=HALF_SECTION then
          data_inner(0)<=input;
        end if;
      elsif state=ST_SEND1 then
        if counter=HALF_SECTION then
          data_inner(1)<=input;
        end if;
      elsif state=ST_SEND2 then
        if counter=HALF_SECTION then
          data_inner(2)<=input;
        end if;
      elsif state=ST_SEND3 then
        if counter=HALF_SECTION then
          data_inner(3)<=input;
        end if;
      elsif state=ST_SEND4 then
        if counter=HALF_SECTION then
          data_inner(4)<=input;
        end if;
      elsif state=ST_SEND5 then
        if counter=HALF_SECTION then
          data_inner(5)<=input;
        end if;
      elsif state=ST_SEND6 then
        if counter=HALF_SECTION then
          data_inner(6)<=input;
        end if;
      elsif state=ST_SEND7 then
        if counter=HALF_SECTION then
          data_inner(7)<=input;
        end if;
      elsif state=ST_STOP  then
        data<=data_inner;
        working<='0';
--      else     --illegal
--        --do nothing
--      end if;
      end if;
    end if;
	
  end process;

  state_move:process(clk)
  begin
    if rising_edge(clk) then
      if state=ST_IDLE then
        if working='1' then
          state<=ST_START;
          counter<="0000000000000000";
        end if;
      elsif state=ST_STOP then
        if counter=HALF_SECTION then
          state<=ST_IDLE;
          counter<="0000000000000000";
        else
          counter<=counter+"000000000000001";
        end if;
      else
        if counter=SECTION then
          counter<="0000000000000000";
          state<=state+"0001";
        else
          counter<=counter+"0000000000000001";
        end if;
      end if;--state
    end if;--rising_edge
  end process;
end RTL;
