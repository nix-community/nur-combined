{
  inputs,
  ...
}:

{
  imports = [
    # https://github.com/hercules-ci/flake-parts/pull/285
    # inputs.flake-parts.flakeModules.flakeModules
    inputs.flake-parts.flakeModules.modules
    inputs.git-hooks-nix.flakeModule

    ./flake-modules.nix
    ./home-modules.nix
    ./modules.nix
    ./nixos-modules.nix
    ./per-system
    ./systems.nix
  ];
}
