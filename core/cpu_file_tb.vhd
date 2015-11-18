--3------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date:   03:03:15 10/07/2015
-- Design Name:
-- Module Name:   /home/yukiimai/Sandbox/2015_winter/carina/cpu_tb.vhd
-- Project Name:  Carina
-- Target Device:
-- Tool versions:
-- Description:
-- --
-- VHDL Test Bench Created by ISE for module: cpu
--
-- Dependencies:
--
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes:
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;


library work;
use work.p_type.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;

ENTITY cpu_tb IS
END cpu_tb;
    --e Component Declaration for the Unit Under Test (UUT)

architecture pohe of cpu_tb is

  COMPONENT cpu
    PORT(
      clk : IN  std_logic;
      IO_empty : IN  std_logic;
      IO_full : IN  std_logic;
      IO_recv_data : IN  std_logic_vector(31 downto 0);
      IO_WE : OUT  std_logic;
      IO_RE : OUT  std_logic;
      IO_send_data : OUT  std_logic_vector(31 downto 0);
      word_access:out std_logic;
      --SRAM
      SRAM_ADDR:out std_logic_vector(19 downto 0);
      SRAM_DATA:inout datat;
      SRAM_WE:out std_logic;
      DEBUG : OUT  top_debug_out
      );
  END COMPONENT;

  component mem_monkey
    port (
      ZD    : inout std_logic_vector(31 downto 0);
      ZA    : in   std_logic_vector(19 downto 0);
      XWA   : in   std_logic;
      clk   : in   std_logic
      );
  end component;

   --Inputs
  signal clk : std_logic := '0';
  signal DEBUG : top_debug_out;
  signal IO_empty : std_logic := '1';
  signal IO_full : std_logic := '0';
  signal IO_RE : std_logic;
  signal IO_recv_data : std_logic_vector(31 downto 0) := (others => '0');
  signal IO_WE : std_logic;
  signal output:datat;
  signal SRAM_ADDR: std_logic_vector(19 downto 0);
  signal SRAM_WE:std_logic;
  signal SRAM_DATA:datat;
  signal word_access :std_logic;
  signal IO_send_data : std_logic_vector(31 downto 0);

  -- Clock period definitions
  constant clk_period : time := 15 ns;


--FILEIO
  type    BIN is file of character;
  file    FILEPOINT   :   BIN open READ_MODE is "loopback.o";
BEGIN
	-- Instantiate the Unit Under Test (UUT)
  uut: cpu PORT MAP (
    clk => clk,
    IO_empty => IO_empty,
    IO_full => IO_full,
    IO_recv_data => IO_recv_data,
    IO_WE => IO_WE,
    IO_RE => IO_RE,
    IO_send_data => IO_send_data,
    word_access=>word_access,
  --SRAM
    SRAM_ADDR=>SRAM_ADDR,
    SRAM_DATA=>SRAM_DATA,
    SRAM_WE=>SRAM_WE,
    DEBUG => DEBUG
  );
  mem:mem_monkey
    port map (
      ZD  =>SRAM_DATA,
      ZA =>SRAM_ADDR,
      XWA  =>SRAM_WE,
      clk  =>clk
    );
   -- Clock process definitions
   output<= io_send_data when word_access='1' else
            x"000000" & io_send_data(7 downto 0);
   clk_process :process
   begin
     clk <= '0';
     wait for clk_period/2;
     clk <= '1';
     wait for clk_period/2;
   end process;

   iof:process (clk)
   begin
     if rising_edge(clk) then
       if io_we='1' then
         io_full<='1';
       else
         io_full<='0';
       end if;
     end if;
   end process;
   -- Stimulus process
   stim_proc: process
     variable FREAD_CHAR:character;
     variable data:datat:=x"00000000";
   begin
      -- hold reset state for 100 ns.
      wait for 100 ns;

      wait for clk_period*10;

      -- insert stimulus here
		--wait until rising_edge(clk);
      while(endfile(FILEPOINT)=false) loop
        if word_access='1' then
          read( FILEPOINT, FREAD_CHAR );
          data(31 downto 24):=(conv_std_logic_vector(CHARacter'pos(FREAD_CHAR),8));
          read( FILEPOINT, FREAD_CHAR );
          data(23 downto 16):=(conv_std_logic_vector(CHARacter'pos(FREAD_CHAR),8));
          read( FILEPOINT, FREAD_CHAR );
          data(15 downto 8):=(conv_std_logic_vector(CHARacter'pos(FREAD_CHAR),8));
          read( FILEPOINT, FREAD_CHAR );
          data(7 downto 0):=(conv_std_logic_vector(CHARacter'pos(FREAD_CHAR),8));
        else
          read( FILEPOINT, FREAD_CHAR );
          data:=x"000000" &(conv_std_logic_vector(CHARacter'pos(FREAD_CHAR),8));
        end if;
        io_recv_data<=data;
        io_empty<='0';
        if io_re='0' then
          wait until  io_re='1';
        end if;
        io_empty<='1';
        wait for clk_period*10;
      end loop;
      wait;
   end process;

end;
