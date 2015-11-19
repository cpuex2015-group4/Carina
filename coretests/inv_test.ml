let cr =dbl (float_of_int 270) /. 400.0 -. 1.5 in
let ci= dbl (float_of_int 46) /. 400 -. 1.0 in
print_int (int_of_float (cr *. 100));
print_int (int_of_float (ci *. 100))
