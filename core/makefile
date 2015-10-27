FILES=$(wildcard hakeisimu/*.vhd)

sim:
	rm hakeisimu -r
	mkdir hakeisimu
	cp *.vhd hakeisimu/
	rm hakeisimu/Carina.vhd
	ghdl -a --ieee=synopsys -fexplicit $(FILES)
	ghdl -a --ieee=synopsys -fexplicit $(FILES)
	ghdl -a --ieee=synopsys -fexplicit $(FILES)
	ghdl -e $(basename $(FILES))
	gtkwaves hakeisimu/cpu_tb.vhd

