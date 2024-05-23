{ super, lib }:

with super.attrsets;

{
  partialFunc =
    f: args1: args2:
    f (recursiveMerge [
      args1
      args2
    ]);
}
