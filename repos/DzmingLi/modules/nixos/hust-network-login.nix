{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.hust-network-login;
in
{
  options.services.hust-network-login = {
    enable = mkEnableOption "HUST campus network login service";

    package = mkOption {
      type = types.package;
      default = pkgs.hust-network-login;
      defaultText = literalExpression "pkgs.hust-network-login";
      description = "The hust-network-login package to use.";
    };

    username = mkOption {
      type = types.str;
      description = "HUST campus network username (student/staff ID)";
    };

    password = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = ''
        HUST campus network password.
        WARNING: This will be stored in the Nix store in plaintext.
        Consider using passwordFile instead for better security.
      '';
    };

    passwordFile = mkOption {
      type = types.nullOr types.path;
      default = null;
      description = ''
        Path to a file containing the HUST campus network password.
        Recommended for better security. Compatible with agenix and other secret management tools.
      '';
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.password != null || cfg.passwordFile != null;
        message = "Either services.hust-network-login.password or services.hust-network-login.passwordFile must be set";
      }
      {
        assertion = !(cfg.password != null && cfg.passwordFile != null);
        message = "Cannot set both password and passwordFile, choose one";
      }
    ];

    systemd.services.hust-network-login = {
      description = "HUST Campus Network Login Service";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        Type = "simple";
        Restart = "always";
        RestartSec = "1";
        DynamicUser = true;
        Environment = "HUST_NETWORK_LOGIN_USERNAME=${cfg.username}";
      } // (if cfg.passwordFile != null then {
        ExecStart = let
          wrapper = pkgs.writeShellScript "hust-network-login-wrapper" ''
            export HUST_NETWORK_LOGIN_PASSWORD="$(cat "$CREDENTIALS_DIRECTORY/password")"
            exec ${cfg.package}/bin/hust-network-login
          '';
        in "${wrapper}";
        LoadCredential = "password:${cfg.passwordFile}";
      } else {
        ExecStart = "${cfg.package}/bin/hust-network-login";
        EnvironmentFile = pkgs.writeText "hust-network-login-env" ''
          HUST_NETWORK_LOGIN_PASSWORD=${cfg.password}
        '';
      });
    };
  };
}
