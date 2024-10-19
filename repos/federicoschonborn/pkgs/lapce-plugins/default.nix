{ callPackage }:

let
  fetchLapcePlugin = callPackage ./fetchLapcePlugin.nix { };
  mkLapcePlugin = callPackage ./mkLapcePlugin.nix { inherit fetchLapcePlugin; };
in

{
  inherit fetchLapcePlugin mkLapcePlugin;
}
// callPackage ./plugins.nix { inherit mkLapcePlugin; }
