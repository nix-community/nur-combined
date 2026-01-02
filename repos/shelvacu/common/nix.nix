{
  config,
  lib,
  pkgs,
  vacuModuleType,
  ...
}:
let
  inherit (lib) mkOption types;
  cfg = config.vacu.nix;
  enabledCaches = builtins.filter (c: c.enable) (builtins.attrValues cfg.caches);
  substituterUrls = map (c: c.url) enabledCaches;
  trustedKeys = builtins.concatMap (c: c.keys) enabledCaches;

  nixPackage =
    if vacuModuleType == "nixos" || vacuModuleType == "nix-on-droid" then
      config.nix.package.out
    else
      pkgs.nix.out;

  fmt = pkgs.formats.nixConf {
    package = nixPackage;
    inherit (cfg) checkAllErrors checkConfig extraOptions;
    inherit (nixPackage) version;
  };

  confFile = fmt.generate "vacu-nix.conf" cfg.settings;

  cacheModule =
    { ... }:
    {
      options = {
        url = mkOption { type = types.str; };
        keys = mkOption {
          type = types.listOf types.str;
          default = [ ];
        };
        enable = mkOption {
          default = true;
          type = types.bool;
        };
      };
    };
in
{
  imports =
    [ ]
    ++ lib.optional (vacuModuleType == "nixos" || vacuModuleType == "nix-on-droid") {
      nix.extraOptions = ''
        include ${confFile}
      '';
    }
    ++ lib.optional (vacuModuleType == "nixos") {
      nix.settings = {
        substituters = lib.mkForce [ ];
        extra-substituters = lib.mkForce [ ];
        trusted-public-keys = lib.mkForce [ ];
        extra-trusted-public-keys = lib.mkForce [ ];
      };
    }
    ++ lib.optional (vacuModuleType == "nix-on-droid") {
      nix = {
        substituters = lib.mkForce [ ];
        trustedPublicKeys = lib.mkForce [ ];
      };
    };
  options.vacu.nix = {
    caches = mkOption {
      type = types.attrsOf (types.submodule cacheModule);
      default = { };
    };

    settings = mkOption {
      # inherit (fmt) type;
      type =
        let
          atom = types.nullOr (
            types.oneOf [
              types.bool
              types.int
              types.float
              types.str
              types.path
              types.package
              (types.listOf atom)
            ]
          );
        in
        types.attrsOf atom;
      default = { };
    };

    checkConfig = mkOption {
      type = types.bool;
      default = true;
      description = ''
        If enabled, checks that Nix can parse the generated nix.conf.
      '';
    };

    checkAllErrors = mkOption {
      type = types.bool;
      default = true;
      description = ''
        If enabled, checks the nix.conf parsing for any kind of error. When disabled, checks only for unknown settings.
      '';
    };

    extraOptions = mkOption {
      type = types.lines;
      default = "";
    };
  };
  config.vacu.nix.settings = {
    substituters = lib.mkForce substituterUrls;
    extra-substituters = lib.mkForce [ ];
    trusted-public-keys = lib.mkForce trustedKeys;
    extra-trusted-public-keys = lib.mkForce [ ];

    extra-experimental-features = [
      "nix-command"
      "flakes"
    ];
    extra-trusted-users = [ "@wheel" ];
  };
}
