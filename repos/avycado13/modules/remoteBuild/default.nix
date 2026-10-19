#
# NixOS module for setting up a remote build user and configuring nix-daemon for remote builds.
# This module creates a 'remotebuild' user, manages SSH keys for access, and configures systemd and nix-daemon
# for remote build use. Enable with `remoteBuild.enable = true;` and provide SSH public keys via `pubKeyFiles` or `pubKeys`.
#
{
  config,
  lib,
  ...
}:
let
  cfg = config.remoteBuild;
in
{
  options.remoteBuild = {
    enable = lib.mkEnableOption "Nix remote build setup";
    pubKeyFiles = lib.mkOption {
      description = "Path to the public key file for the Nix remote build";
      type = lib.types.listOf lib.types.path;
      default = [ "./remotebuild.pub" ];
    };
    pubKeys = lib.mkOption {
      description = "Inline SSH public keys for the remote build user.";
      type = lib.types.listOf lib.types.str;
      default = [ ];
    };
    extraServiceConfig = lib.mkOption {
      description = "Extra systemd serviceConfig options for nix-daemon.";
      type = lib.types.attrsOf lib.types.anything;
      default = { };
    };
    # Resource and logging options
    maxMemoryUsage = lib.mkOption {
      description = "Maximum memory usage for the Nix daemon";
      type = lib.types.str;
      default = "90%";
    };
    logLevel = lib.mkOption {
      description = "Verbosity of nix-daemon logs.";
      type = lib.types.enum [
        "debug"
        "info"
        "warn"
        "error"
      ];
      default = "info";
    };
  };

  assertions = [
    {
      assertion = cfg.enable -> (cfg.pubKeyFiles != [ ] || cfg.pubKeys != [ ]);
      message = "remoteBuild: At least one of pubKeyFiles or pubKeys must be non-empty when remoteBuild.enable is true.";
    }
  ];

  config = lib.mkIf cfg.enable {
    users.users.remotebuild = {
      isNormalUser = true;
      createHome = false;
      group = "remotebuild";

      openssh.authorizedKeys.keyFiles = lib.mkAfter cfg.pubKeyFiles;
      openssh.authorizedKeys.keys = lib.mkAfter cfg.pubKeys;
    };

    users.groups.remotebuild = { };

    nix = {
      nrBuildUsers = 64;
      settings = {
        trusted-users = lib.mkAfter [ "remotebuild" ];
        min-free = 10 * 1024 * 1024;
        max-free = 200 * 1024 * 1024;

        max-jobs = "auto";
        cores = 0;
        log-level = cfg.logLevel;
      };
    };

    systemd.services.nix-daemon.serviceConfig = lib.mkMerge [
      {
        MemoryAccounting = true;
        MemoryMax = cfg.maxMemoryUsage;
        OOMScoreAdjust = 500;
      }
      cfg.extraServiceConfig
    ];
  };
}
