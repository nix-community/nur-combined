with builtins;
let
  filter = fn: items:
    if (length items) == 0 
      then []
      else
    let 
      h = head items;
      t = tail items;
      newH = if (fn h) then [h] else [];
    in newH ++ (filter fn t);
in filter

