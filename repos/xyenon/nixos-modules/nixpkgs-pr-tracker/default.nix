{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.nixpkgs-pr-tracker;
in
{
  options.services.nixpkgs-pr-tracker = {
    enable = lib.mkEnableOption "nixpkgs pr-tracker";

    package = lib.mkPackageOption pkgs "pr-tracker" { };

    user = lib.mkOption {
      type = lib.types.nonEmptyStr;
      default = "nixpkgs-pr-tracker";
      description = "User account under which nixpkgs pr-tracker runs.";
    };

    group = lib.mkOption {
      type = lib.types.nonEmptyStr;
      default = "nixpkgs-pr-tracker";
      description = "Group under which nixpkgs pr-tracker runs.";
    };

    nixpkgsPath = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/nixpkgs.git";
      description = "Path to the nixpkgs repository.";
    };

    nixpkgsUpdateOnCalendar = lib.mkOption {
      type = lib.types.nonEmptyStr;
      default = "hourly";
      description = ''
        Calendar time to update the nixpkgs repository.
        See {manpage}`systemd.time(7)` for details.
      '';
    };

    args = lib.mkOption {
      type = with lib.types; listOf str;
      description = "Command-line arguments.";
      default = [
        "--remote"
        "origin"
        "--user-agent"
        "pr-tracker (alyssais)"
        "--source-url"
        "https://git.qyliss.net/pr-tracker"
      ];
    };

    githubTokenFile = lib.mkOption {
      type = lib.types.path;
      description = "Path to a file containing the GitHub token.";
    };

    listenStreams = lib.mkOption {
      type = with lib.types; listOf str;
      description = ''
        TCP sockets to bind to.
        See [](#opt-systemd.sockets._name_.listenStreams).
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    systemd = {
      services = {
        nixpkgs-pr-tracker = {
          description = "Nixpkgs pr-tracker";
          requires = [ "nixpkgs-pr-tracker.socket" ];
          path = with pkgs; [ git ];
          serviceConfig = {
            ExecStart = "${lib.getExe cfg.package} ${
              lib.strings.escapeShellArgs (
                [
                  "--path"
                  cfg.nixpkgsPath
                ]
                ++ cfg.args
              )
            }";
            NonBlocking = true;
            StandardInput = "file:${cfg.githubTokenFile}";
            User = cfg.user;
            Group = cfg.group;
          };
        };
        nixpkgs-pr-tracker-fetch = {
          description = "Fetch nixpkgs repository";
          after = [ "network-online.target" ];
          requires = [ "network-online.target" ];
          path = with pkgs; [ git ];
          serviceConfig = {
            ExecStart = "${lib.getExe pkgs.git} fetch --all";
            WorkingDirectory = cfg.nixpkgsPath;
            User = cfg.user;
            Group = cfg.group;
          };
        };
      };

      sockets.nixpkgs-pr-tracker = {
        description = "Nixpkgs pr-tracker socket";
        inherit (cfg) listenStreams;
        socketConfig = {
          SocketUser = cfg.user;
          SocketGroup = cfg.group;
        };
        wantedBy = [ "sockets.target" ];
      };

      timers.nixpkgs-pr-tracker-fetch = {
        description = "Fetch nixpkgs repository";
        timerConfig = {
          OnCalendar = cfg.nixpkgsUpdateOnCalendar;
          Persistent = true;
        };
        wantedBy = [ "timers.target" ];
      };
    };

    users = {
      users.${cfg.user} = {
        inherit (cfg) group;
        isSystemUser = true;
      };
      groups.${cfg.group} = { };
    };
  };
}
