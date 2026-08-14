{
  config,
  lib,
  inputs,
  ...
}:
let
  cfg = config.nixcfg.nix;
  # cache.toyvo.dev is served by nix-serve out of the serving machine's own
  # local nix store, so substituting from it there can never yield anything --
  # and resolving it loops out to the WAN and back (hairpin).
  cacheSubstituters = [
    "https://cache.nixos.org"
    "https://nix-community.cachix.org"
  ]
  ++ lib.optional (!cfg.excludeOwnCache) "https://cache.toyvo.dev";
in
{
  options.nixcfg.nix = {
    enable = lib.mkEnableOption "nix configuration";
    excludeOwnCache = lib.mkOption {
      type = lib.types.bool;
      default = config.services.nix-serve.enable or false;
      defaultText = lib.literalExpression "config.services.nix-serve.enable or false";
      description = ''
        Exclude cache.toyvo.dev from substituters. Defaults to true on machines
        that serve the cache via nix-serve, since everything it publishes is
        already in the local nix store.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    nix = {
      settings = {
        experimental-features = [
          "nix-command"
          "flakes"
          "pipe-operators"
        ];
        substituters = cacheSubstituters;
        trusted-substituters = cacheSubstituters;
        trusted-public-keys = [
          "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
          "cache.toyvo.dev:6bv4Qc2/SVaWnWzDOUcoB4pT3i3l4wcM+WrhRBFb7E4="
        ];
      };
      nixPath = [
        "nixpkgs=${inputs.nixos-unstable}"
      ];
    };
  };
}
