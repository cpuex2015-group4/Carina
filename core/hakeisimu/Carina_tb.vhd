--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   21:33:46 10/06/2015
-- Design Name:   
-- Module Name:   /home/yukiimai/Sandbox/2015_winter/Carina/Carina_tb.vhd
-- Project Name:  Carina
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: top
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
 
ENTITY Carina_tb IS
END Carina_tb;
 
ARCHITECTURE behavior OF Carina_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT top
    PORT(
         MCLK1 : IN  std_logic;
         RS_TX : OUT  std_logic;
         ZD : INOUT  std_logic_vector(31 downto 0);
         ZA : OUT  std_logic_vector(19 downto 0);
         XWA : OUT  std_logic;
         XE1 : OUT  std_logic;
         E2A : OUT  std_logic;
         XE3 : OUT  std_logic;
         XGA : OUT  std_logic;
         XZCKE : OUT  std_logic;
         ADVA : OUT  std_logic;
         XLBO : OUT  std_logic;
         ZZA : OUT  std_logic;
         XFT : OUT  std_logic;
         XZBE : OUT  std_logic_vector(3 downto 0);
         ZCLKMA : OUT  std_logic_vector(1 downto 0);
			DEBUG:out top_debug_out
        );
    END COMPONENT;
    

   --Inputs
   signal MCLK1 : std_logic := '0';

	--BiDirs
   signal ZD : std_logic_vector(31 downto 0);

 	--Outputs
   signal RS_TX : std_logic;
   signal ZA : std_logic_vector(19 downto 0);
   signal XWA : std_logic;
   signal XE1 : std_logic;
   signal E2A : std_logic;
   signal XE3 : std_logic;
   signal XGA : std_logic;
   signal XZCKE : std_logic;
   signal ADVA : std_logic;
   signal XLBO : std_logic;
   signal ZZA : std_logic;
   signal XFT : std_logic;
   signal XZBE : std_logic_vector(3 downto 0);
   signal ZCLKMA : std_logic_vector(1 downto 0);
   signal DEBUG : top_debug_out;
   -- No clocks detected in port list. Replace <clock> below with 
   -- appropriate port name 
 
	constant MCLK_period:time:=14 ns;
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: top PORT MAP (
          MCLK1 => MCLK1,
          RS_TX => RS_TX,
          ZD => ZD,
          ZA => ZA,
          XWA => XWA,
          XE1 => XE1,
          E2A => E2A,
          XE3 => XE3,
          XGA => XGA,
          XZCKE => XZCKE,
          ADVA => ADVA,
          XLBO => XLBO,
          ZZA => ZZA,
          XFT => XFT,
          XZBE => XZBE,
          ZCLKMA => ZCLKMA,
			 DEBUG=>DEBUG
        );

   -- Clock process definitions
   MCLK_process :process
   begin
		MCLK1 <= '0';
		wait for MCLK_period/2;
		MCLK1 <= '1';
		wait for MCLK_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	

      wait for MCLK_period*10;

      -- insert stimulus here 

      wait;
   end process;

END;
