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
      description = "Group account under which nixpkgs pr-tracker runs.";
    };

    args = lib.mkOption {
      type = with lib.types; listOf str;
      description = "Command-line arguments.";
      default = [
        "--path"
        "/var/lib/nixpkgs.git"
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
      services.nixpkgs-pr-tracker = {
        description = "Nixpkgs pr-tracker";
        requires = [ "nixpkgs-pr-tracker.socket" ];
        path = with pkgs; [ git ];
        serviceConfig = {
          ExecStart = "${lib.getExe cfg.package} ${lib.strings.escapeShellArgs cfg.args}";
          NonBlocking = true;
          StandardInput = "file:${cfg.githubTokenFile}";
          User = cfg.user;
          Group = cfg.group;
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
