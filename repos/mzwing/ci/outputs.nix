# The derivations actually built by the coordinator's "Build package outputs"
# step of .github/workflows/build.yml, restricted to the systems that have
# uncached targets. The system list is passed in via the BUILD_SYSTEMS
# environment variable as a JSON array:
#
#   BUILD_SYSTEMS='["x86_64-linux"]' nix build --impure --file ci/outputs.nix
#
# --impure is required for BUILD_SYSTEMS itself.
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
