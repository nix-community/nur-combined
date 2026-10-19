{
  config,
  pkgs,
  lib,
  ...
}:
let
  paths = [
    "${config.home.homeDirectory}/Documents"
    "${config.home.homeDirectory}/Downloads"
    "${config.home.homeDirectory}/Desktop"
  ];
in
{
  options.dots.restic.enable = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = "Enable the restic dotfiles module.";
  };

  config = lib.mkIf config.dots.restic.enable {
    sops.secrets = {
      restic-repository-password = {
        sopsFile = ../../../../secrets/services.yaml;
        key = "restic/repository_password";
      };
      restic-b2-credentials = {
        sopsFile = ../../../../secrets/services.yaml;
        key = "restic/b2_credentials";
      };
    };
    services.restic.enable = true;
    services.restic.backups.laptop = {
      repository = "b2:avyrestic:laptop";
      passwordFile = config.sops.secrets.restic-repository-password.path;
      environmentFile = config.sops.secrets.restic-b2-credentials.path;
    };

    # services.restic's paths/timerConfig/pruneOpts options are Linux-only
    # (home-manager marks them readOnly on Darwin, see modules/services/restic.nix
    # upstream), so scheduling on macOS is done via launchd directly, sourcing the
    # same repository/password/env config the module wires up above.
    launchd.agents.restic-laptop-backup = {
      enable = true;
      config = {
        ProgramArguments = [
          "${pkgs.writeShellScript "restic-laptop-backup" ''
            set -euo pipefail
            export RESTIC_REPOSITORY=b2:avyrestic:laptop
            export RESTIC_PASSWORD_FILE=${config.sops.secrets.restic-repository-password.path}
            set -a
            source ${config.sops.secrets.restic-b2-credentials.path}
            set +a
            ${pkgs.restic}/bin/restic snapshots >/dev/null 2>&1 || ${pkgs.restic}/bin/restic init
            ${pkgs.restic}/bin/restic backup ${builtins.concatStringsSep " " paths} --exclude-caches --one-file-system
            ${pkgs.restic}/bin/restic forget --prune --keep-daily 7 --keep-weekly 4 --keep-monthly 3
          ''}"
        ];
        StartCalendarInterval = [
          {
            Hour = 3;
            Minute = 30;
          }
        ];
        StandardOutPath = "${config.home.homeDirectory}/Library/Logs/restic-laptop-backup.log";
        StandardErrorPath = "${config.home.homeDirectory}/Library/Logs/restic-laptop-backup.log";
      };
    };
  };
}
