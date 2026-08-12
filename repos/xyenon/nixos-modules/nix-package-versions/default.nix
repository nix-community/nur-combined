{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.nix-package-versions;
in
{
  options.services.nix-package-versions = {
    enable = lib.mkEnableOption "nix package versions";

    package = lib.mkPackageOption pkgs "nur.repos.xyenon.nix-package-versions" { };

    user = lib.mkOption {
      type = lib.types.nonEmptyStr;
      default = "nix-package-versions";
      description = "User account under which nix-package-versions runs.";
    };

    group = lib.mkOption {
      type = lib.types.nonEmptyStr;
      default = "nix-package-versions";
      description = "Group under which nix-package-versions runs.";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 8080;
      description = "nix-package-versions port.";
    };

    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Open port in the firewall for nix-package-versions.";
    };

    dataDir = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/nix-package-versions";
      description = "The directory where nix-package-versions stores its files.";
    };

    databaseUpdateOnCalendar = lib.mkOption {
      type = lib.types.nonEmptyStr;
      default = "weekly";
      description = "Calendar time to update the nix-package-versions database.  See {manpage}`systemd.time(7)` for details.";
    };

    databaseUpdateArgs = lib.mkOption {
      type = with lib.types; listOf str;
      description = "Command-line arguments.";
      default = [
        "--from"
        "2020-01-01"
      ];
    };

    githubUser = lib.mkOption {
      type = lib.types.nonEmptyStr;
      description = "GitHub user account.";
    };

    githubTokenFile = lib.mkOption {
      type = lib.types.path;
      description = "Path to a file containing the GitHub token.";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd = {
      services =
        let
          databasePath = "${cfg.dataDir}/database";
        in
        {
          nix-package-versions = {
            description = "Nix package versions";
            serviceConfig = {
              ExecStart = "${lib.getExe cfg.package} server ${
                lib.escapeShellArgs [
                  "--port"
                  cfg.port
                  "--db-root"
                  databasePath
                ]
              }";
              User = cfg.user;
              Group = cfg.group;
            };
            wantedBy = [ "multi-user.target" ];
          };
          nix-package-versions-database-update = {
            description = "Update nix-package-versions database";
            after = [ "network-online.target" ];
            requires = [ "network-online.target" ];
            path = with pkgs; [ nix ];
            serviceConfig = {
              ExecStart =
                let
                  updateScript = pkgs.writers.writeBashBin "nix-package-versions-database-update" ''
                    ${lib.getExe cfg.package} update ${
                      lib.escapeShellArgs (
                        [
                          "--github-user"
                          cfg.githubUser
                          "--db-root"
                          databasePath
                        ]
                        ++ cfg.databaseUpdateArgs
                      )
                    } --github-token $(<${lib.escapeShellArg cfg.githubTokenFile})
                  '';
                in
                "${updateScript}/bin/nix-package-versions-database-update";
              User = cfg.user;
              Group = cfg.group;
            };
          };
        };

      timers.nix-package-versions-database-update = {
        description = "Update nix-package-versions database";
        timerConfig = {
          OnCalendar = cfg.databaseUpdateOnCalendar;
          Persistent = true;
        };
        wantedBy = [ "timers.target" ];
      };
    };

    networking.firewall = lib.mkIf cfg.openFirewall {
      allowedTCPPorts = [ cfg.port ];
    };

    users = {
      users.${cfg.user} = {
        inherit (cfg) group;
        isSystemUser = true;
        createHome = true;
        home = cfg.dataDir;
      };
      groups.${cfg.group} = { };
    };
  };
}
