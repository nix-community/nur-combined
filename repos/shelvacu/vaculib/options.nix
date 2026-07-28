{ lib, ... }:
let
  inherit (builtins)
    length
    head
    tail
    foldl'
    ;
  inherit (lib.options) showOption prioritySuggestion showDefs;
in
{
  options = {
    # same as lib.options.mergeEqualOption except you can provide a function, and the comparison compares the result of that function on the value
    mergeEqualOptionBy =
      func: loc: defs:
      if defs == [ ] then
        abort "This case should never happen."
      # Returns early if we only have one element
      # This also makes it work for functions, because the foldl' below would try
      # to compare the first element with itself, which is false for functions
      else if length defs == 1 then
        (head defs).value
      else
        (foldl' (
          first: def:
          if (func def.value) != (func first.value) then
            throw "The option `${showOption loc}' has conflicting definition values:${
              showDefs [
                first
                def
              ]
            }\n${prioritySuggestion}"
          else
            first
        ) (head defs) (tail defs)).value;
  };
}
