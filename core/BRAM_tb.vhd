--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   21:59:56 10/12/2015
-- Design Name:   
-- Module Name:   /home/yukiimai/Sandbox/2015_winter/Carina/core/BRAM_tb.vhd
-- Project Name:  Carina
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: BRAM_INST
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
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY BRAM_tb IS
END BRAM_tb;
 
ARCHITECTURE behavior OF BRAM_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT BRAM_INST
    PORT(
         clka : IN  std_logic;
         wea : IN  std_logic_vector(0 downto 0);
         addra : IN  std_logic_vector(13 downto 0);
         dina : IN  std_logic_vector(31 downto 0);
         douta : OUT  std_logic_vector(31 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal clka : std_logic := '0';
   signal wea : std_logic_vector(0 downto 0) := (others => '0');
   signal addra : std_logic_vector(13 downto 0) := (others => '0');
   signal dina : std_logic_vector(31 downto 0) := (others => '0');

 	--Outputs
   signal douta : std_logic_vector(31 downto 0);

   -- Clock period definitions
   constant clka_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: BRAM_INST PORT MAP (
          clka => clka,
          wea => wea,
          addra => addra,
          dina => dina,
          douta => douta
        );

   -- Clock process definitions
   clka_process :process
   begin
		clka <= '0';
		wait for clka_period/2;
		clka <= '1';
		wait for clka_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	

      wait for clka_period*10;

      -- insert stimulus here
		wea<="1";
		for i in 10 to 100 loop
			addra<=CONV_STD_lOGIC_Vector(i,14);
			dina<=CONV_STD_LOGIC_vector(i+100,32);
			wait for clka_period;
		end loop;
		wea<="0";
		for i in 0 to 110 loop
			addra<=conv_std_logic_vector(i,14);
			wait for clka_period;
		end loop;
		wait;
	end process;
END;
