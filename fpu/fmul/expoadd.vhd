library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity expoAdd is
  port (
	  expoA   : in  std_logic_vector (7 downto 0);
		expoB   : in  std_logic_vector (7 downto 0);
		expoO1  : out std_logic_vector (7 downto 0);
		expoO2  : out std_logic_vector (7 downto 0);
		uFlag1  : out std_logic;
		uFlag2  : out std_logic);
end expoAdd;

architecture struct of expoadd is
  signal added1 : std_logic_vector (8 downto 0);
	signal added2 : std_logic_vector (8 downto 0);
begin
  added1   <= ("0" & expoA) + ("0" & expoB) - "001111111";
	added2   <= ("0" & expoA) + ("0" & expoB) - "001111110";
	expoO1   <= added1(7 downto 0);
	expoO2   <= added2(7 downto 0);
	-- 最上位ビットが1かつその次が0->アンダーフロー
	-- 最上位ビットが1かつその次が1->オーバーフロー
	uFlag1   <= added1(8);
	uFlag2   <= added2(8);
end struct;

