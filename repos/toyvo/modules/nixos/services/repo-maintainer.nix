{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.repo-maintainer;
in
{
  options.services.repo-maintainer = {
    enable = lib.mkEnableOption "durable Forgejo repo maintainer (polls CI, reruns infra cancels, opens fix PRs)";

    package = lib.mkOption {
      type = lib.types.nullOr lib.types.package;
      default = null;
      description = "The repo-maintainer package to run (e.g. inputs.nixcfg.packages.\${system}.repo-maintainer; system pkgs carry no custom overlay)";
    };

    stateDir = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/repo-maintainer";
      description = "Directory for durable state (attempt checkpoints). Copy this to relocate the service.";
    };

    pollIntervalSec = lib.mkOption {
      type = lib.types.int;
      default = 420;
      description = "Seconds between Forgejo API polls";
    };

    maxReruns = lib.mkOption {
      type = lib.types.int;
      default = 3;
      description = "Max automatic reruns per infra-cancelled job before giving up";
    };

    model = lib.mkOption {
      type = lib.types.str;
      default = "opencode-go/muse-spark-1.3-contributor";
      description = "Model used when writing fixes";
    };

    repo = lib.mkOption {
      type = lib.types.str;
      default = "toyvo/nixcfg";
      description = "Forgejo repo (owner/name) to watch";
    };

    forgejoApiUrl = lib.mkOption {
      type = lib.types.str;
      default = "https://git.toyvo.dev/api/v1";
      description = "Forgejo API base URL";
    };

    forgejoLogDir = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/forgejo/data/actions_log";
      description = "Forgejo actions_log directory (task .log files live here)";
    };

    environmentFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "Environment file supplying FORGEJO_TOKEN (and model API keys), e.g. a sops secret";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.environmentFile != null;
        message = "services.repo-maintainer.environmentFile must be set (FORGEJO_TOKEN)";
      }
      {
        assertion = cfg.package != null;
        message = "services.repo-maintainer.package must be set (e.g. inputs.nixcfg.packages.\${system}.repo-maintainer)";
      }
    ];

    users.users.repo-maintainer = {
      isSystemUser = true;
      group = "repo-maintainer";
    };
    users.groups.repo-maintainer = { };

    systemd.tmpfiles.rules = [
      "d ${cfg.stateDir} 0700 repo-maintainer repo-maintainer -"
    ];

    systemd.services.repo-maintainer = {
      description = "Durable Forgejo repo maintainer";
      wantedBy = [ "multi-user.target" ];
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      # Don't SIGTERM our own watch on every rebuild (same lesson as the
      # forgejo-runner: mid-poll kills look like infra cancels).
      restartIfChanged = false;
      serviceConfig = {
        User = "repo-maintainer";
        Group = "repo-maintainer";
        EnvironmentFile = cfg.environmentFile;
        Restart = "always";
        RestartSec = "30s";
      };
      script = ''
        exec ${lib.getExe cfg.package} \
          --repo ${lib.escapeShellArg cfg.repo} \
          --base-url ${lib.escapeShellArg cfg.forgejoApiUrl} \
          --state-dir ${lib.escapeShellArg cfg.stateDir} \
          --forgejo-log-dir ${lib.escapeShellArg cfg.forgejoLogDir} \
          --max-reruns ${toString cfg.maxReruns}
      '';
      environment = {
        MAINTAINER_REPO = cfg.repo;
        MAINTAINER_STATE_DIR = cfg.stateDir;
        MAINTAINER_MODEL = cfg.model;
        MAINTAINER_POLL_INTERVAL_SEC = toString cfg.pollIntervalSec;
      };
    };
  };
}
