let size = 325 in
let table = create_array size 0 in
let rec init_table _ =
  table.(0) <- -70;
  table.(1) <- 35;
  table.(2) <- -20;
  table.(3) <- 20;
  table.(4) <- 30;
  table.(5) <- 1;
  table.(6) <- 50;
  table.(7) <- 50;
  table.(8) <- 255;
  table.(9) <- 0;
  table.(10) <- 1;
  table.(11) <- 1;
  table.(12) <- 0;
  table.(13) <- 20;
  table.(14) <- 20;
  table.(15) <- 65;
  table.(16) <- 0;
  table.(17) <- 20;
  table.(18) <- 45;
  table.(19) <- 1;
  table.(20) <- 1;
  table.(21) <- 250;
  table.(22) <- 128;
  table.(23) <- 210;
  table.(24) <- 0;
  table.(25) <- 0;
  table.(26) <- 3;
  table.(27) <- 1;
  table.(28) <- 0;
  table.(29) <- 25;
  table.(30) <- 40;
  table.(31) <- 70;
  table.(32) <- 0;
  table.(33) <- 0;
  table.(34) <- 40;
  table.(35) <- 1;
  table.(36) <- 1;
  table.(37) <- 250;
  table.(38) <- 128;
  table.(39) <- 210;
  table.(40) <- 0;
  table.(41) <- 0;
  table.(42) <- 3;
  table.(43) <- 1;
  table.(44) <- 0;
  table.(45) <- 0;
  table.(46) <- 30;
  table.(47) <- 30;
  table.(48) <- 0;
  table.(49) <- -5;
  table.(50) <- 0;
  table.(51) <- -1;
  table.(52) <- 1;
  table.(53) <- 250;
  table.(54) <- 128;
  table.(55) <- 211;
  table.(56) <- 0;
  table.(57) <- 0;
  table.(58) <- 1;
  table.(59) <- 1;
  table.(60) <- 0;
  table.(61) <- 20;
  table.(62) <- 10;
  table.(63) <- 30;
  table.(64) <- 0;
  table.(65) <- -10;
  table.(66) <- 80;
  table.(67) <- 1;
  table.(68) <- 1;
  table.(69) <- 250;
  table.(70) <- 128;
  table.(71) <- 211;
  table.(72) <- 0;
  table.(73) <- 0;
  table.(74) <- 2;
  table.(75) <- 1;
  table.(76) <- 0;
  table.(77) <- 0;
  table.(78) <- -1;
  table.(79) <- -1;
  table.(80) <- 0;
  table.(81) <- 0;
  table.(82) <- 50;
  table.(83) <- 1;
  table.(84) <- 1;
  table.(85) <- 250;
  table.(86) <- 128;
  table.(87) <- 211;
  table.(88) <- 0;
  table.(89) <- 0;
  table.(90) <- 1;
  table.(91) <- 1;
  table.(92) <- 0;
  table.(93) <- 22;
  table.(94) <- 28;
  table.(95) <- 28;
  table.(96) <- 0;
  table.(97) <- -5;
  table.(98) <- 0;
  table.(99) <- 1;
  table.(100) <- 1;
  table.(101) <- 250;
  table.(102) <- 0;
  table.(103) <- 211;
  table.(104) <- 211;
  table.(105) <- 0;
  table.(106) <- 3;
  table.(107) <- 1;
  table.(108) <- 0;
  table.(109) <- 40;
  table.(110) <- 28;
  table.(111) <- 28;
  table.(112) <- 0;
  table.(113) <- -5;
  table.(114) <- 0;
  table.(115) <- 1;
  table.(116) <- 1;
  table.(117) <- 250;
  table.(118) <- 0;
  table.(119) <- 211;
  table.(120) <- 211;
  table.(121) <- 0;
  table.(122) <- 3;
  table.(123) <- 1;
  table.(124) <- 0;
  table.(125) <- 0;
  table.(126) <- 15;
  table.(127) <- 15;
  table.(128) <- 0;
  table.(129) <- -5;
  table.(130) <- 0;
  table.(131) <- -1;
  table.(132) <- 1;
  table.(133) <- 250;
  table.(134) <- 0;
  table.(135) <- 211;
  table.(136) <- 211;
  table.(137) <- 0;
  table.(138) <- 3;
  table.(139) <- 1;
  table.(140) <- 0;
  table.(141) <- 15;
  table.(142) <- 25;
  table.(143) <- 25;
  table.(144) <- 0;
  table.(145) <- -5;
  table.(146) <- 70;
  table.(147) <- 1;
  table.(148) <- 1;
  table.(149) <- 250;
  table.(150) <- 211;
  table.(151) <- 0;
  table.(152) <- 0;
  table.(153) <- 0;
  table.(154) <- 1;
  table.(155) <- 1;
  table.(156) <- 0;
  table.(157) <- 5;
  table.(158) <- 11;
  table.(159) <- 45;
  table.(160) <- 0;
  table.(161) <- 35;
  table.(162) <- 40;
  table.(163) <- 1;
  table.(164) <- 1;
  table.(165) <- 250;
  table.(166) <- 211;
  table.(167) <- 128;
  table.(168) <- 0;
  table.(169) <- 0;
  table.(170) <- 3;
  table.(171) <- 1;
  table.(172) <- 0;
  table.(173) <- 30;
  table.(174) <- 45;
  table.(175) <- 75;
  table.(176) <- 0;
  table.(177) <- 0;
  table.(178) <- 40;
  table.(179) <- 1;
  table.(180) <- 1;
  table.(181) <- 250;
  table.(182) <- 211;
  table.(183) <- 128;
  table.(184) <- 0;
  table.(185) <- 0;
  table.(186) <- 1;
  table.(187) <- 1;
  table.(188) <- 0;
  table.(189) <- 25;
  table.(190) <- 41;
  table.(191) <- 70;
  table.(192) <- 0;
  table.(193) <- 5;
  table.(194) <- 40;
  table.(195) <- 1;
  table.(196) <- 1;
  table.(197) <- 250;
  table.(198) <- 0;
  table.(199) <- 0;
  table.(200) <- 0;
  table.(201) <- 1;
  table.(202) <- 1;
  table.(203) <- 1;
  table.(204) <- 0;
  table.(205) <- 100;
  table.(206) <- 5;
  table.(207) <- 200;
  table.(208) <- 0;
  table.(209) <- -35;
  table.(210) <- 150;
  table.(211) <- 1;
  table.(212) <- 1;
  table.(213) <- 250;
  table.(214) <- 200;
  table.(215) <- 200;
  table.(216) <- 200;
  table.(217) <- 0;
  table.(218) <- 3;
  table.(219) <- 1;
  table.(220) <- 0;
  table.(221) <- 25;
  table.(222) <- 10;
  table.(223) <- 10;
  table.(224) <- 0;
  table.(225) <- -5;
  table.(226) <- 0;
  table.(227) <- 1;
  table.(228) <- 1;
  table.(229) <- 250;
  table.(230) <- 211;
  table.(231) <- 128;
  table.(232) <- 128;
  table.(233) <- 0;
  table.(234) <- 3;
  table.(235) <- 2;
  table.(236) <- 0;
  table.(237) <- 25;
  table.(238) <- 20;
  table.(239) <- 20;
  table.(240) <- 0;
  table.(241) <- 0;
  table.(242) <- 70;
  table.(243) <- 1;
  table.(244) <- 0;
  table.(245) <- 0;
  table.(246) <- 0;
  table.(247) <- 0;
  table.(248) <- 255;
  table.(249) <- 2;
  table.(250) <- 3;
  table.(251) <- 1;
  table.(252) <- 0;
  table.(253) <- 20;
  table.(254) <- 20;
  table.(255) <- 20;
  table.(256) <- 100;
  table.(257) <- 40;
  table.(258) <- 120;
  table.(259) <- 1;
  table.(260) <- 1;
  table.(261) <- 150;
  table.(262) <- 255;
  table.(263) <- 255;
  table.(264) <- 255;
  table.(265) <- 0;
  table.(266) <- 2;
  table.(267) <- 2;
  table.(268) <- 0;
  table.(269) <- 0;
  table.(270) <- 0;
  table.(271) <- -1;
  table.(272) <- 0;
  table.(273) <- 0;
  table.(274) <- 200;
  table.(275) <- 1;
  table.(276) <- 0;
  table.(277) <- 0;
  table.(278) <- 255;
  table.(279) <- 0;
  table.(280) <- 0;
  table.(281) <- -1;
  table.(282) <- 0;
  table.(283) <- 1;
  table.(284) <- 2;
  table.(285) <- -1;
  table.(286) <- 3;
  table.(287) <- 1;
  table.(288) <- 4;
  table.(289) <- -1;
  table.(290) <- 5;
  table.(291) <- 6;
  table.(292) <- 7;
  table.(293) <- -1;
  table.(294) <- 8;
  table.(295) <- -1;
  table.(296) <- 9;
  table.(297) <- 10;
  table.(298) <- -1;
  table.(299) <- 12;
  table.(300) <- -1;
  table.(301) <- 13;
  table.(302) <- -1;
  table.(303) <- 14;
  table.(304) <- -1;
  table.(305) <- 15;
  table.(306) <- -1;
  table.(307) <- 16;
  table.(308) <- -1;
  table.(309) <- -1;
  table.(310) <- 11;
  table.(311) <- 0;
  table.(312) <- 1;
  table.(313) <- 2;
  table.(314) <- 3;
  table.(315) <- 4;
  table.(316) <- 6;
  table.(317) <- -1;
  table.(318) <- 99;
  table.(319) <- 9;
  table.(320) <- 8;
  table.(321) <- 7;
  table.(322) <- 5;
  table.(323) <- -1;
  table.(324) <- -1;
in
let rec loopback n =
  if n >= size then n
  else
    (
    let x = int_of_float (read_float ()) in
    print_int x; print_char 32; print_int table.(n); print_newline();
    if x <> table.(n) then
      if x <> table.(n) - 1 then n
      else loopback (n + 1)
    else loopback (n + 1)
    )
in
init_table ();
loopback 0
