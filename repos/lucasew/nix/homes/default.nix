{ flake, extraArgs, nodes }:
let
  hmConf = {
    modules,
    pkgs,
    extraSpecialArgs ? {}
  }:
  import "${flake.inputs.home-manager}/modules" {
    inherit pkgs;
    extraSpecialArgs = extraArgs // extraSpecialArgs // { inherit pkgs; };
    configuration = { imports = modules; };
  };
in builtins.mapAttrs (k: v: hmConf v) nodes
