# CI build and cache targets for every supported system.
let
  flake = builtins.getFlake "path:${toString ../.}";
  systems = import ../internal/systems.nix;
in
  builtins.concatMap (
    system: let
      pkgs = flake.inputs.nixpkgs.legacyPackages.${system};
    in
      (import ./. {inherit pkgs;}).cacheTargets
  )
  systems
