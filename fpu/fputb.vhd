LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.all;

library UNISIM;
use UNISIM.Vcomponents.all;

entity top is
  port( MCLK1 : in  std_logic;
        RS_TX : out std_logic);
end top;

architecture testbench of top is
  signal clk  : std_logic;
  signal iclk : std_logic;
  signal send : std_logic := '1';
  signal full : std_logic := '0';
  
  component serialif port (
    serialO : out std_logic;
	  dataIN  : in  std_logic_vector(7 downto 0);
	  send    : in  std_logic;
	  full    : out std_logic;
	  clk     : in  std_logic);
  end component;
    
  component fmul port (
    inputA : in  std_logic_vector (31 downto 0);
    inputB : in  std_logic_vector (31 downto 0);
    output : out std_logic_vector (31 downto 0));
  end component;
   
  component finv port (
    clk    : in  std_logic;
    input  : in  std_logic_vector (31 downto 0);
    output : out std_logic_vector (31 downto 0));
  end component;
  
  component fcmp port (
    inputA : in  std_logic_vector (31 downto 0);
    inputB : in  std_logic_vector (31 downto 0);
    mode   : in  std_logic_vector ( 5 downto 0);
    output : out std_logic);
  end component;

  signal inputA    : std_logic_vector (31 downto 0) := "01000000010000000000000000000000"; -- 3.0
  signal inputB    : std_logic_vector (31 downto 0) := "01000000101000000000000000000000"; -- 5.0
  signal mode      : std_logic_vector ( 5 downto 0) := "111100";
  signal muloutput : std_logic_vector (31 downto 0);
  signal mulanswer : std_logic_vector (31 downto 0) := "01000001011100000000000000000001";
  signal invoutput : std_logic_vector (31 downto 0);
  signal invanswer : std_logic_vector (31 downto 0) := "00111110101010101010101010101001"; -- 0.33...
  signal cmpoutput : std_logic;
  signal cmpanswer : std_logic := '1';
  signal tb_result : std_logic_vector (7 downto 0) := "00000000";
  
  signal mulcorrect: std_logic;
  signal invcorrect: std_logic;
  signal cmpcorrect: std_logic;
begin
  ib : IBUFG port map (
    i => MCLK1,
	  o => iclk);
  bg : BUFG port map (
    i => iclk,
	  o => clk);

  mul_u : fmul port map (
    inputA => inputA,
    inputB => inputB,
    output => muloutput);
    
  inv_u : finv port map (
    clk    => clk,
    input  => inputA,
    output => invoutput);
    
  cmp_u : fcmp port map (
    inputA => inputA,
    inputB => inputB,
    mode   => mode,
    output => cmpoutput);
  
  rc232c : serialif port map (
    serialO => rs_tx,
	  dataIN  => tb_result,
	  send    => send,
	  full    => full,
	  clk     => clk);
    
  cmp_ans : process(clk)
  begin
    if rising_edge(clk) then
      if muloutput = mulanswer then
        mulcorrect <= '1';
      end if;
      if invoutput = invanswer then
        invcorrect <= '1';
      end if;
      if cmpoutput = cmpanswer then
        cmpcorrect <= '1';
      end if;
	  end if;
  end process;
  tb_result <= "00000" & mulcorrect & invcorrect & cmpcorrect;
  send <= not full;
end;
