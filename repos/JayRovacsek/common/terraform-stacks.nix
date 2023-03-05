{ self }:
let
  stacks = builtins.attrNames (builtins.readDir ../terranix);
  cfg = builtins.foldl' (acc: stack:
    {
      ${stack} = import ../terranix/${stack} { inherit self; };
    } // acc) { } stacks;
in cfg
