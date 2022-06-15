{ inputs, ... }:

let
  inherit (inputs.nixpkgs.lib) genAttrs systems;
  #pkgs_systems = systems.flakeExposed; 
  pkgs_systems = [ "x86_64-linux" ];

in
{
  importAttrset = path: builtins.mapAttrs (_: import) (import path);
  forAllSystems = f: genAttrs pkgs_systems (system: f system);
}