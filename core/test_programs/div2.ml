let rec div2 n=
  print_int n;print_char 32;
  if n=0 then () else div2 (n/2)
in div2 1000;
