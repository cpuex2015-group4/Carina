let x0 = -10.0 in
let x1 = 10.0 in
let step = 0.01 in
let rec plot x =
  if x > x1 then ()
  else (
    print_float x;
    print_float (sin x);
    plot (x +. step)
  )
in plot x0
