{ flake, extraArgs, nodes, mkPkgs }:
let
  inherit (flake.inputs) nix-on-droid home-manager;
  nixOnDroidConf = {
    modules,
    system
  }:
  import "${flake.inputs.nix-on-droid}/modules" {
    config = {
      _module.args = extraArgs;
      home-manager.config._module.args = extraArgs;
      imports = modules;
    };
    pkgs = mkPkgs {
      overlays = (import "${nix-on-droid}/overlays");
      inherit system;
    };
    home-manager = import home-manager {};
    isFlake = true;
  };
in builtins.mapAttrs (k: v: nixOnDroidConf v) nodes
