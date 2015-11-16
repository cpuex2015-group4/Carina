--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   20:44:21 10/13/2015
-- Design Name:   
-- Module Name:   /home/yukiimai/Sandbox/2015_winter/Carina/core/IO_tb.vhd
-- Project Name:  Carina
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: IO_module
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
 
ENTITY IO_tb IS
END IO_tb;
 
ARCHITECTURE behavior OF IO_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT IO_module
    PORT(
         clk : IN  std_logic;
         WE : IN  std_logic;
         RE : IN  std_logic;
         send_data : IN  std_logic_vector(7 downto 0);
         recv_data : OUT  std_logic_vector(7 downto 0);
         full : OUT  std_logic;
         empty : OUT  std_logic;
         serial_send : OUT  std_logic;
         serial_recv : IN  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal WE : std_logic := '0';
   signal RE : std_logic := '0';
   signal send_data : std_logic_vector(7 downto 0) := (others => '0');
   signal serial_recv : std_logic := '0';

 	--Outputs
   signal recv_data : std_logic_vector(7 downto 0);
   signal full : std_logic;
   signal empty : std_logic;
   signal serial_send : std_logic;

   -- Clock period definitions
   constant clk_period : time := 15 ns;
	
	 constant ROMMAX:Integer:=10;
   type rom_t is array (0 to ROMMAX) of std_logic_vector(31 downto 0);
   constant rom:rom_t:=(
	  conv_std_logic_vector(0,32),
	  	  conv_std_logic_vector(7,32),
		  	  conv_std_logic_vector(100,32),
			  	  conv_std_logic_vector(4,32),
    "00100000000000010000000000000000",
    "00100000000000100000000000000001",
    "00000000001000100001100000100000",
    "00000000000000100000100000100000",
    "00000000000000110001000000100000",
	 "01101100000000110000000000000000",
    "00001000000000000000000000000010");
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: IO_module PORT MAP (
          clk => clk,
          WE => WE,
          RE => RE,
          send_data => send_data,
          recv_data => recv_data,
          full => full,
          empty => empty,
          serial_send => serial_send,
          serial_recv => serial_recv
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
		eternal:loop
        for I in 0 to ROMMAX loop
          serial_recv<='0';
          wait for 0.104 ms;
          for J in 0 to 7 loop
            serial_recv<=rom(I)(31 downto 24)(J);
            wait for 0.104 ms;
          end loop;
          serial_recv<='1';
          wait for 0.104 ms;
			 
			         serial_recv<='0';
          wait for 0.104 ms;
          for J in 0 to 7 loop
            serial_recv<=rom(I)(23 downto 16)(J);
            wait for 0.104 ms;
          end loop;
          serial_recv<='1';
          wait for 0.104 ms;
			 
			         serial_recv<='0';
          wait for 0.104 ms;
          for J in 0 to 7 loop
            serial_recv<=rom(I)(15 downto 8)(J);
            wait for 0.104 ms;
          end loop;
          serial_recv<='1';
          wait for 0.104 ms;
			 
			         serial_recv<='0';
          wait for 0.104 ms;
          for J in 0 to 7 loop
            serial_recv<=rom(I)(7 downto 0)(J);
            wait for 0.104 ms;
          end loop;
          serial_recv<='1';
          wait for 0.104 ms;
        end loop;
      end loop eternal;
   end process;
	
	read_proc:process(clk)
	begin
		if empty='0' then
			RE<='1';
		else
			RE<='0';
		end if;
	end process;


	writeproc:process
	begin
          wait for 100 ns;
          if full ='1' then
            wait until falling_edge(full);
          end if;
          wait until rising_edge(clk);
          send_data<=x"11";
          we<='1';
          wait for clk_period;

          if full ='1' then
            wait until falling_edge(full);
          end if;
          wait until rising_edge(clk);
          send_data<=x"22";
          we<='1';
          wait for clk_period;

          if full ='1' then
            wait until falling_edge(full);
          end if;
          wait until rising_edge(clk);
          send_data<=x"33";
          we<='1';
          wait for clk_period;
      end process; 
END;
