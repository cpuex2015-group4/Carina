--------------------------------------------------------------------------------
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
         DEBUG : OUT  top_debug_out
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal IO_empty : std_logic := '0';
   signal IO_full : std_logic := '0';
   signal IO_recv_data : std_logic_vector(31 downto 0) := (others => '0');

 	--Outputs
   signal IO_WE : std_logic;
   signal IO_RE : std_logic;
   signal IO_send_data : std_logic_vector(31 downto 0);
   signal DEBUG : top_debug_out;

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
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
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	

      wait for clk_period*10;

      -- insert stimulus here 

      wait;
   end process;

END;
