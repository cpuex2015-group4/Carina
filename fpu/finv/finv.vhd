library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity finv is
  port (
    clk    : in  std_logic;
	  input  : in  std_logic_vector (31 downto 0);
		output : out std_logic_vector (31 downto 0));
end finv;

architecture struct of finv is
  type float is record
	  sign : std_logic;
		expo : std_logic_vector ( 7 downto 0);
		mant : std_logic_vector (22 downto 0);
	end record;

  component finv_table is
	  port (
		  CLKA  : in  std_logic;
			ADDRA : in  std_logic_vector ( 9 downto 0); -- テーブル引きするmantの上位10bit - 1bit(ケチ表現)
			DOUTA : out std_logic_vector (31 downto 0)); -- 定数項24bit & 勾配8bit
	end component;

	signal input_f  : float;
	signal output_f : float;

  signal rom_en   : std_logic := '0';
  signal rom_addr : std_logic_vector ( 9 downto 0);
  signal rom_data : std_logic_vector (31 downto 0);
	signal const    : std_logic_vector (22 downto 0);
	signal grad     : std_logic_vector (22 downto 0);
	signal mant     : std_logic_vector (22 downto 0);

begin
	rom_addr <= input(22 downto 13);

	finv_table_rom : finv_table port map (
	  CLKA  => clk,
		ADDRA => rom_addr,
		DOUTA => rom_data);

  grad <= ("1" & rom_data( 8 downto 0)) * input_f.mant(12 downto 0);

-- Underflowの場合を追加すべき
  output_f.sign <= input_f.sign;
	output_f.expo <= 253 - input_f.expo; -- 指数部を計算
	output_f.mant <= rom_data(31 downto 9) - ("000000000" & grad(22 downto 10)); -- ニュートン法からfinvmanを計算

  holo : process(clk)
  begin
    if rising_edge(clk) then
      input_f.sign <= input(31);
    	input_f.expo <= input(30 downto 23);
    	input_f.mant <= input(22 downto  0);    
    end if;
  end process;
  
  output <= output_f.sign & output_f.expo & output_f.mant;
end struct;