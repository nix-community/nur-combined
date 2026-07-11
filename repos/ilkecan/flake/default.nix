{
  inputs,
  ...
}:

{
  imports = [
    inputs.flake-parts.flakeModules.flakeModules
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
