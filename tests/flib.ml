(*
 * fequal, fless, fispos, fisneg,
 * fiszero, fhalf, fsqr, fnegのテスト
 *)
let x = 0.5 in
if (fless (fsqr x) x) then
  if (fispos (fhalf x)) then
    if (fiszero ((fneg x) +. x)) then
      if (fequal ((fneg x) +. x) 0.0) then
        if (fisneg (fneg x)) then
          1
        else 0
      else 0
    else 0
  else 0
else 0
