# Cacheable outputs for systems listed in the impure `BUILD_SYSTEMS` JSON variable.
let
  flake = builtins.getFlake "path:${toString ../.}";
  systems = builtins.fromJSON (builtins.getEnv "BUILD_SYSTEMS");
in
  builtins.concatMap (
    system: let
      pkgs = flake.inputs.nixpkgs.legacyPackages.${system};
    in
      (import ./. {inherit pkgs;}).cacheOutputs
  )
  systems
