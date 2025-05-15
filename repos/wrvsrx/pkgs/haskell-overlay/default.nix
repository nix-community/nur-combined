{ sources, pkgs }:
final: prev:
let
  inherit (prev) callPackage;
in
{
  osc52 = callPackage ./osc52 { source = sources.osc52; };
  task-utils = callPackage ./task-utils { source = sources.task-utils; };
}
