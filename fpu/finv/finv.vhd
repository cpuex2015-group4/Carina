library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity finv is
  port (
	  input  : in  std_logic_vector (31 downto 0);
		output : out std_logic_vector (31 downto 0));
--  exflag : out std_logic_vector ( 3 downto 0); -- オーバーフローなどのフラグ管理用
--  busy   : out std_logic);
end finv;

architecture struct of finv is
  type float is record
	  sign : std_logic;
		expo : std_logic_vector ( 7 downto 0);
		mant : std_logic_vector (22 downto 0);
	end record;

  component finv_table_rom is
	  port (
		  en   : in  std_logic;
			addr : in  std_logic_vector ( 9 downto 0); -- テーブル引きするmantの上位10bit
			data : out std_logic_vector (35 downto 0)); -- 定数項23bit & 勾配13bit
	end component;

	signal input_f  : float;
	signal output_f : float;

  signal rom_en   : std_logic := '0';
  signal rom_addr : std_logic_vector ( 9 downto 0);
  signal rom_data : std_logic_vector (31 downto 0);
	signal const    : std_logic_vector (22 downto 0);
	signal grad     : std_logic_vector (12 downto 0);
	signal mant     : std_logic_vector (23 downto 0);

begin
  input_f.sign <= input(31);
	input_f.expo <= input(30 downto 23);
	input_f.mant <= input(22 downto  0);

	rom_addr <= input_f.mant(22 downo 13);

	finv_table : finv_table_rom port map (
	  en   => rom_en,
		addr => rom_addr,
		data => rom_data);

	mant <= rom(31 downto 8) - rom_data(7 downto 0) * input_f.mant(12 downto 0);

-- Underflowの場合を追加すべき
  output_f.sign <= input_f.sign;
	output_f.expo <= 254 - input_f.expo when mant(23) = 1 else
	                 253 - input_f.expo; -- 指数部を計算
	output_f.mant <= mant(22 downto 0)       when mant(23) = 1 else
	                 mant(21 downto 0) & "0"; -- ニュートン法からfinvmanを計算

  output <= output_f.sign & output_f.expo & output_f.mant;
end struct;

