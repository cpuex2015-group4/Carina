--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   04:19:56 10/14/2015
-- Design Name:   
-- Module Name:   /home/yukiimai/Sandbox/2015_winter/Carina/core/loader_tb.vhd
-- Project Name:  Carina
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: loader
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
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY loader_tb IS
END loader_tb;
 
ARCHITECTURE behavior OF loader_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT loader
    PORT(
         clk : IN  std_logic;
         IO_empty : IN  std_logic;
         activate : IN  std_logic;
         IO_recv_data : IN  std_logic_vector(31 downto 0);
         addr : OUT  std_logic_vector(13 downto 0);
         din : OUT  std_logic_vector(31 downto 0);
         bram_we : OUT  std_logic_vector(0 downto 0);
         IO_RE : OUT  std_logic;
         loaded : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal IO_empty : std_logic := '1';
   signal activate : std_logic := '0';
   signal IO_recv_data : std_logic_vector(31 downto 0) := (others => '0');

 	--Outputs
   signal addr : std_logic_vector(13 downto 0);
   signal din : std_logic_vector(31 downto 0);
   signal bram_we : std_logic_vector(0 downto 0):="0";
   signal IO_RE : std_logic;
   signal loaded : std_logic;

   -- Clock period definitions
   constant clk_period : time := 15 ns;
 
 
	 constant ROMMAX:Integer:=9;
   type rom_t is array (0 to ROMMAX) of std_logic_vector(31 downto 0);
   constant rom:rom_t:=(
	x"ffffffff",x"00000003",x"00000100",x"00000002",
	x"11111111",x"22222222",x"33333333",x"44444444",x"55555555",x"66666666");
	
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: loader PORT MAP (
          clk => clk,
          IO_empty => IO_empty,
          activate => activate,
          IO_recv_data => IO_recv_data,
          addr => addr,
          din => din,
          bram_we => bram_we,
          IO_RE => IO_RE,
          loaded => loaded
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
		activate<='1';
		wait for clk_period;
      -- insert stimulus here 
   eternal:loop
        for I in 0 to ROMMAX loop
			 wait for clk_period*10;
			 io_recv_data<=rom(I);
			 io_empty<='0';
			 
			 wait until io_re='1';
			 io_empty<='1';
			 wait for clk_period;
        end loop;
		  wait;
      end loop eternal; 
      wait;
   end process;

END;
