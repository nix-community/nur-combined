{ lib, vaculib, ... }:
let
  inherit (lib) mkOption types;
  pluralRename =
    name:
    lib.doRename {
      from = [ name ];
      to = [ "${name}s" ];
      visible = true;
      warn = false;
      use = x: x;
    };
in
{
  options.data.nix.caches = mkOption {
    default = { };
    type = types.attrsOf (types.submodule {
      # modules = [
      #   (pluralRename "key")
      # ];
      options = {
        enable = mkOption {
          default = true;
          type = types.bool;
        };
        url = mkOption {
          type = vaculib.types.storeUrl;
        };
        key = mkOption {
          default = [ ];
          type = vaculib.types.listOrSingle vaculib.types.nixPublicKey;
        };
      };
    });
  };
  config.data.nix.caches = {
    vacu = {
      url = "https://nixcache.shelvacu.com/";
      key = "nixcache.shelvacu.com:73u5ZGBpPRoVZfgNJQKYYBt9K9Io/jPwgUfuOLsJbsM=";
    };
    nix-community = {
      url = "https://nix-community.cachix.org/";
      key = "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=";
      enable = false;
    };
    nix-on-droid = {
      url = "https://nix-on-droid.cachix.org/";
      key = "nix-on-droid.cachix.org-1:56snoMJTXmDRC1Ei24CmKoUqvHJ9XCp+nidK7qkMQrU=";
      enable = false;
    };
    nixos = {
      url = "https://cache.nixos.org/";
      key = "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=";
    };
  };
}
