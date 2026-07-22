{
  config,
  lib,
  inputs,
  ...
}:
let
  cfg = config.nixcfg.nix;
in
{
  options.nixcfg.nix.enable = lib.mkEnableOption "nix configuration";

  config = lib.mkIf cfg.enable {
    nix = {
      settings = {
        experimental-features = [
          "nix-command"
          "flakes"
          "pipe-operators"
        ];
        substituters = config.nix.settings.trusted-substituters;
        trusted-substituters = [
          "https://cache.nixos.org"
          "https://nix-community.cachix.org"
          "https://cache.toyvo.dev"
        ];
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
