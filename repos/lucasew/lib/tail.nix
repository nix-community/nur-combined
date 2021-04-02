let
  last = arr:
    if (builtins.length arr == 0) then null
    else
      if (builtins.length arr == 1) then builtins.head arr
      else (last (builtins.tail arr));
in
last
