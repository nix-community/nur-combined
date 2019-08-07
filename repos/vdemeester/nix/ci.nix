{sources ? import ./sources.nix}:
let
  # nix-build doesn't traverse names with periods...
  targetConfigs = {
    "nixpkgs-unstable" = {
      nixpkgsSource = "nixpkgs-unstable";
      system = "x86_64-linux";
    };
    "nixos-unstable" = {
      nixpkgsSource = "nixos-unstable";
      system = "x86_64-linux";
    };
    "nixos-19_03" = {
      nixpkgsSource = "nixos-19.03";
      system = "x86_64-linux";
    };
  };

  recurseIntoAttrs = as: as // { recurseForDerivations = true; };

  canBuild = name: (p: (p.meta.unsupported == name));

  targets = builtins.mapAttrs packagesFor targetConfigs;

  packagesFor = _targetName: targetConfig:
    import ../default.nix {
      inherit (targetConfig) nixpkgsSource system;
      allTargets = builtins.filter targets;
    };

in recurseIntoAttrs targets
