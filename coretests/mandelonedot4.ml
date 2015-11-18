let rec dbl f = f +. f in
let cr = -0.15 in
let ci = -0.77 in
let i=1000 in
let zr=0.0 in
let zi = 0.0 in
let zr2=0.0 in
let zi2 = 0.0 in
let tr = zr2 -. zi2 +. cr in
let ti = dbl zr *. zi +. ci in
let zr = tr in
let zi = ti in
let zr2 = zr *. zr in
let zi2 = zi *. zi in
if zr2 +. zi2 > 2.0 *. 2.0 then print_int 0 else
  print_int 1
