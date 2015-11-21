let rec mul4 n=
  print_int n;print_char 32;
  if n>10000 then () else mul4 (n*4)
in mul4 1;
