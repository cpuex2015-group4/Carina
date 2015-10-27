--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   12:21:16 10/13/2015
-- Design Name:   
-- Module Name:   /home/yukiimai/Sandbox/2015_winter/Carina/core/io32_tb.vhd
-- Project Name:  Carina
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: IO32
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
 
ENTITY io32_tb IS
END io32_tb;
 
ARCHITECTURE behavior OF io32_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT IO32
    PORT(
         clk : IN  std_logic;
         WE : IN  std_logic;
         RE : IN  std_logic;
         send_data : IN  std_logic_vector(31 downto 0);
         recv_data : OUT  std_logic_vector(31 downto 0);
         full : OUT  std_logic;
         empty : OUT  std_logic;
         serial_send : OUT  std_logic;
         serial_recv : IN  std_logic;
         word_access : IN  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal WE : std_logic := '0';
   signal RE : std_logic := '0';
   signal send_data : std_logic_vector(31 downto 0) := (others => '0');
   signal serial_recv : std_logic := '1';
   signal word_access : std_logic := '0';

 	--Outputs
   signal recv_data : std_logic_vector(31 downto 0);
   signal full : std_logic;
   signal empty : std_logic;
   signal serial_send : std_logic;

   -- Clock period definitions
   constant clk_period : time := 15 ns;
 
   constant ROMMAX:Integer:=9;
   type rom_t is array (0 to ROMMAX) of std_logic_vector(7 downto 0);
   constant rom:rom_t:=(x"11",x"22",x"33",x"44",x"55",x"66",x"77",x"88",x"99",x"aa");
	
	 constant SENDROMMAX:Integer:=2;
   type sendrom_t is array (0 to SENDROMMAX) of std_logic_vector(31 downto 0);
   constant sendrom:sendrom_t:=(x"00000000",x"FFFFFFFF",x"F0F0F0F0");
	
BEGIN

   uut: IO32 PORT MAP (
          clk => clk,
          WE => WE,
          RE => RE,
          send_data => send_data,
          recv_data => recv_data,
          full => full,
          empty => empty,
          serial_send => serial_send,
          serial_recv => serial_recv,
          word_access => word_access
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
   stim_recvproc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 0.104 ms*	10;	

      wait for clk_period*10;

      -- insert stimulus here
      eternal:loop
        for I in 0 to ROMMAX loop
          serial_recv<='0';
          wait for 0.104 ms;
          for J in 0 to 7 loop
            serial_recv<=rom(I)(J);
            wait for 0.104 ms;
          end loop;
          serial_recv<='1';
          wait for 0.104 ms;
        end loop;
      end loop eternal;
   end process;
	
		writeproc:process
	begin
          wait for 100 ns;
          if full ='1' then
            wait until falling_edge(full);
          end if;
          wait until rising_edge(clk);
          send_data<=x"11111111";
          we<='1';
          wait for clk_period;

          if full ='1' then
            wait until falling_edge(full);
          end if;
          wait until rising_edge(clk);
          send_data<=x"22222222";
          we<='1';
          wait for clk_period;

          if full ='1' then
            wait until falling_edge(full);
          end if;
          wait until rising_edge(clk);
          send_data<=x"33333333";
          we<='1';
          wait for clk_period;
      end process; 

	REPROC:process(clk)
	begin
	if rising_edge(clk) then
		if empty='0' then
		  re<='1';
		 else
		   re<='0';
		end if;
	end if;
	
	end process;
END;
