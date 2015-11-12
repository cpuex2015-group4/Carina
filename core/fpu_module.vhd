library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

library work;
use work.p_type.all;

entity fpu is    --single しか使わないので fmt は省いてあります
port (
  funct:in functt;
  data1: in datat:=x"00000000";
  data2: in datat:=x"00000000";
  result:out datat:=x"00000000";
  FPCond:out std_logic:='0'
);
end fpu;

architecture nobunaga of fpu is
  component fadd
    port(
      ina:in datat;
      inb:in datat;
      output:out datat
      );
  end component;

  component fmul
    port(
      inputa:in datat;
      inputb:in datat;
      output:out datat
      );
  end component;

  component finv
    port(
      input:in datat;
      output:out datat
      );
  end component;

  component fcmp
\    port(
      inputa:in datat;
      inputb:in datat;
      funct:in functt;
      output:out std_logic
    );
  end component;
	signal add_data2:datat:=x"00000000";
	signal add_result:datat:=x"00000000";
	signal mul_result:datat:=x"00000000";
	signal inv_result:datat:=x"00000000";
	
begin
   FA: fadd port maP(
      ina=>data1,
      inb=>add_data2,
      output=>add_result
      );

  fm: fmul
    port map(
      inputa=>data1,
      inputb=>data2,
      output=>mul_result
      );

  fi: finv
    port map(
      input=>data1,
      output=>inv_result
      );

  fc: fcmp
    port map(
      inputa=>data1,
      inputb=>data2,
      funct=>funct,
      output=>FPCond
    );

   add_data2<=(not data2(31)) &data2(30 downto 0) when funct=1 else  --funct=1 ha
                                                                     --sub dayon
               data2 ;

       result<= add_result when funct=0 or funct=1 else --0 add  1 sub
                mul_result when funct=2 else
                inv_result when funct=3;
end nobunaga;
