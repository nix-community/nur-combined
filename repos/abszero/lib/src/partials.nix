{ super }:

let
  inherit (super.attrsets) recursiveMerge;
in

{
  partialFunc =
    f: args1: args2:
    f (recursiveMerge [
      args1
      args2
    ]);
}
