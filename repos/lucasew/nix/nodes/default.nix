{
  path,
  nodes,
  extraArgs,
  system,
  extraModules ? [ ],
}:

let
  nixosConf =
    {
      modules ? [ ],
      extraSpecialArgs ? { },
      pkgs,
    }:
    import "${path}/nixos/lib/eval-config.nix" {
      specialArgs = extraSpecialArgs // extraArgs;
      inherit system pkgs;
      modules = modules ++ extraModules;
    };
in
builtins.mapAttrs (k: v: nixosConf v) nodes
