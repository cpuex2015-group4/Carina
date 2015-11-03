library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity fcmp is
 port(
   inputA : in  std_logic_vector (31 downto 0);
	 inputB : in  std_logic_vector (31 downto 0);
	 mode   : in  std_logic_vector (1  downto 0); -- 00 = disable / 01 = c.le.s / 10 = c.lt.s / 11 = c.eq.s
	 output : out std_logic); -- 10 = false / 11 = true / 00 = disabled
end fcmp;

architecture struct fcmp is
	signal lt;
	signal eq;
begin
	eq <= '1' when inputA(30 downto 0) = 0 and inputB(30 downto 0) = 0 else
	      '1' when inputA = inputB else
				'0';
	lt <= '0' when inputA(30 downto 0) = 0 and inputB(30 downto 0) = 0 else
	      '1' when inputA(31) = '1' and inputB(31) = '0' else
	      '1' when inputA(31) = '1' and inputB(31) = '1' and inputA(30 downto 0) > inputB(30 downto 0) else
				'1' when inputA(31) = '0' and inputB(31) = '0' and inputA(30 downto 0) < inputB(30 downto 0) else
				'0';

	output <= "1" & (lt and eq) when mode = "01" else
	          "1" & lt          when mode = "10" else
						"1" & eq          when mode = "11" else
						"00";
end struct;
