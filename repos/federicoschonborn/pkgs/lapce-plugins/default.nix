{ callPackage }:

let
  fetchLapcePlugin = callPackage ./fetchLapcePlugin.nix { };
  mkLapcePlugin = callPackage ./mkLapcePlugin.nix { inherit fetchLapcePlugin; };
  plugins = callPackage ./plugins.nix { inherit mkLapcePlugin; };
in

{
  inherit fetchLapcePlugin mkLapcePlugin;
}
// plugins
