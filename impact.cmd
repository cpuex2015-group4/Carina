setMode -bs
setCable -port auto
Identify -inferir
identifyMPM
assignFile -p 2 -file "./core/working/top.bit"
Program -p 2
quit