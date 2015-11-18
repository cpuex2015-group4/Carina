let rec test x=
  if x =0 then
	0.1
  else
    (test (x-1))*.2.0
in print_int(int_of_float (test 10))
(* [102.4]=102が想定解  *)
