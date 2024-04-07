{
  path,
  nodes,
  extraArgs,
  system,
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
      inherit system pkgs modules;
    };
in
builtins.mapAttrs (k: v: nixosConf v) nodes
