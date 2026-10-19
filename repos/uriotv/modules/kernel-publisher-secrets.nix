{ config, lib, ... }:
let
  cfg = config.services.urioNur.kernelPublisher;
  complete = cfg.enable && cfg.user != "" && cfg.sopsFile != null;
in
{
  options.services.urioNur.kernelPublisher = {
    enable = lib.mkEnableOption "a sops-nix Cachix token for local kernel publication";
    user = lib.mkOption {
      type = lib.types.str;
      default = "";
      example = "urio";
      description = "Existing local user allowed to read the Cachix write token.";
    };
    sopsFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "Encrypted YAML containing cachix_auth_token; never a plaintext token file.";
    };
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      assertions = [
        {
          assertion = cfg.user != "" && builtins.hasAttr cfg.user config.users.users;
          message = "services.urioNur.kernelPublisher.user must name an existing NixOS user.";
        }
        {
          assertion = cfg.sopsFile != null;
          message = "Set services.urioNur.kernelPublisher.sopsFile to the encrypted cachix.yaml file.";
        }
      ];
    })
    (lib.mkIf complete {
      sops.secrets.cachix_auth_token = {
        inherit (cfg) sopsFile;
        key = "cachix_auth_token";
        format = "yaml";
        owner = cfg.user;
        group = config.users.users.${cfg.user}.group or "users";
        mode = "0400";
      };
    })
  ];
}
