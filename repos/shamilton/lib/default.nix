{ pkgs, gomod2nix }:
let
  builder0 = pkgs.callPackage ./gomod2nix-no-cyclic-deps/builder { };
  gomod2nix0 = pkgs.callPackage ./gomod2nix-no-cyclic-deps { inherit (builder0) buildGoApplication; };
  gomod2nixbuilder = if gomod2nix != null then (gomod2nix + "/builder") else ./gomod2nix/builder;
  builder1 = pkgs.callPackage gomod2nixbuilder { gomod2nix = gomod2nix0; };
in {
  # Add your library functions here
  #
  # hexint = x: hexvals.${toLower x};
  gomod2nix = { inherit (builder1)  buildGoApplication; };
}

