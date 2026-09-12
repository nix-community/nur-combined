final: prev:
let
  inherit (prev) callPackage;
in
{
  task-utils = callPackage ./task-utils { };
}
