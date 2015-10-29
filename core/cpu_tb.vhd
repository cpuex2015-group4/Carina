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
-- 
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
 
ARCHITECTURE behavior OF cpu_tb IS 
 
    --e Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT cpu
    PORT(
         clk : IN  std_logic;
         IO_empty : IN  std_logic;
         IO_full : IN  std_logic;
         IO_recv_data : IN  std_logic_vector(31 downto 0);
         IO_WE : OUT  std_logic;
         IO_RE : OUT  std_logic;
         IO_send_data : OUT  std_logic_vector(31 downto 0);
           --SRAM
  SRAM_ADDR:out std_logic_vector(19 downto 0);
  SRAM_DATA:inout datat;
  SRAM_WE:out std_logic;

         DEBUG : OUT  top_debug_out
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal IO_empty : std_logic := '1';
   signal IO_full : std_logic := '0';
   signal IO_recv_data : std_logic_vector(31 downto 0) := (others => '0');


    signal SRAM_ADDR: std_logic_vector(19 downto 0);
    signal SRAM_DATA:datat;
    signal SRAM_WE:std_logic;
 	--Outputs
   signal IO_WE : std_logic;
   signal IO_RE : std_logic;
   signal IO_send_data : std_logic_vector(31 downto 0);
   signal DEBUG : top_debug_out;

   -- Clock period definitions
   constant clk_period : time := 15 ns;
   
--    constant ROMMAX:Integer:=15;
--       type rom_t is array (0 to ROMMAX) of std_logic_vector(31 downto 0);
--    constant rom:rom_t:=(
--	  conv_std_logic_vector(0,32),
--	  conv_std_logic_vector(12,32),
  	--  conv_std_logic_vector(0,32),
--	  conv_std_logic_vector(5,32),
--    x"6c080000",X"6c080000",x"6c080000",x"6c080000",x"6c080000",
--      x"2001000A", --kouhan is the number);
--      x"20020000",x"00221020",x"2021FFFF",x"1420FFFD",x"6c020000",x"FFFFFFFF"
--  );


        constant ROMMAX:Integer:=8;
       type rom_t is array (0 to ROMMAX) of std_logic_vector(31 downto 0);
    constant rom:rom_t:=(
	  conv_std_logic_vector(0,32),
	  conv_std_logic_vector(3,32),
  	  conv_std_logic_vector(0,32),
	  conv_std_logic_vector(0,32),
    x"68016c01",X"6c010000",x"08000000",x"11111111",x"22222222"  );    


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

  --SRAM
          SRAM_ADDR=>SRAM_ADDR,
          SRAM_DATA=>SRAM_DATA,
          SRAM_WE=>SRAM_WE,

          
          DEBUG => DEBUG
        );

   -- Clock process definitions
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
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	

      wait for clk_period*10;

      -- insert stimulus here
		--wait until rising_edge(clk);
		
		io_empty<='0';

      for I in 0 to ROMMAX loop
			 io_recv_data<=rom(I);
			 io_empty<='0';
			 if io_re='0' then
			   wait until  io_re='1';
			 end if;
			 io_empty<='1';
			 wait for clk_period*10;
			 
      end loop;
      wait;
   end process;

END;
