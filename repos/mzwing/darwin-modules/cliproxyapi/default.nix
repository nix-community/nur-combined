{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.cliproxyapi;
  format = pkgs.formats.yaml {};
  serviceLib = import ../../internal/system-service {inherit lib pkgs;};
  # nixpkgs' own substitution, so `_secret` behaves as in its NixOS module.
  utils = import "${pkgs.path}/nixos/lib/utils.nix" {inherit config lib pkgs;};
  accountIdType = lib.types.ints.between 502 2147483647;

  stateDir = "/var/lib/cliproxyapi";
  configPath = "${stateDir}/config.yaml";

  startScript = pkgs.writeShellApplication {
    name = "cliproxyapi-start";
    text = ''
      ${(utils.genJqSecretsReplacement {} cfg.settings configPath).script}
      exec ${lib.getExe cfg.package} -config ${configPath}
    '';
  };
in {
  options.services.cliproxyapi = {
    enable = lib.mkEnableOption "CLIProxyAPI";

    package = lib.mkPackageOption pkgs "cliproxyapi" {};

    settings = lib.mkOption {
      type = lib.types.submodule {
        freeformType = format.type;
        options = {
          server.port = lib.mkOption {
            type = lib.types.port;
            default = 8317;
            description = "Port on which CLIProxyAPI listens.";
          };
          oauth.auth-dir = lib.mkOption {
            type = lib.types.str;
            default = stateDir;
            description = "Directory where OAuth tokens are stored.";
          };
        };
      };
      default = {};
      description = ''
        Configuration for CLIProxyAPI, written to `${configPath}` at every start, so changes made through the management API do not survive a restart. See the [example configuration](https://github.com/router-for-me/CLIProxyAPI/blob/main/config.example.yaml) for available options. Secret values can be loaded from files using `._secret = "/path/to/secret";`; the service account must be able to read them.
      '';
    };

    uid = lib.mkOption {
      type = accountIdType;
      default = 538;
      description = "UID of the hidden `_cliproxyapi` service account. Override this if the default conflicts with an existing local account.";
    };

    gid = lib.mkOption {
      type = accountIdType;
      default = 538;
      description = "GID of the `_cliproxyapi` service group. Override this if the default conflicts with an existing local group.";
    };
  };

  config = lib.mkIf cfg.enable (serviceLib.mkDarwin {
    name = "cliproxyapi";

    process = {
      executable = lib.getExe startScript;
      workingDirectory = stateDir;
      umask = "0077";
    };

    account = {
      logicalName = "cliproxyapi";
      home = stateDir;
      description = "CLIProxyAPI service user";
      darwin = {inherit (cfg) uid gid;};
    };

    darwin = {
      standardOutPath = "${stateDir}/cliproxyapi.out.log";
      standardErrorPath = "${stateDir}/cliproxyapi.err.log";
    };
  });
}
