{
  config,
  vaculib,
  pkgs,
  lib,
  ...
}:
let
  inherit (lib) mkOption;
  cfg = config.vacu.liam.backup;
  commonServiceConfig = {
    Type = "oneshot";
    StateDirectory = "auto-borg";
    CacheDirectory = "auto-borg";
    ReadOnlyPaths = cfg.paths ++ [ cfg.keyPath ];

    User = cfg.user;
    Group = cfg.user;

    LockPersonality = true;
    MemoryDenyWriteExecute = true;
    PrivateDevices = true;
    # PrivateUsers = true;
    ProcSubset = "pid";
    PrivateTmp = true;
    ProtectClock = true;
    ProtectControlGroups = true;
    ProtectHome = true;
    ProtectHostname = true;
    ProtectKernelLogs = true;
    ProtectKernelModules = true;
    ProtectKernelTunables = true;
    ProtectProc = "invisible";
    ProtectSystem = "strict";
    RestrictAddressFamilies = [
      "AF_INET"
      "AF_INET6"
    ];
    RestrictNamespaces = true;
    RestrictRealtime = true;
    RestrictSUIDSGID = true;
    SystemCallArchitectures = "native";
    SystemCallFilter = [
      "@system-service"
      "~@privileged"
    ];
    UMask = vaculib.maskStr { user = "allow"; };
    AmbientCapabilities = [ "CAP_DAC_READ_SEARCH" ];
    CapabilityBoundingSet = [ "CAP_DAC_READ_SEARCH" ];
  };
in
{
  options.vacu.liam.backup = {
    user = mkOption { default = "autoborger"; };
    rsyncUser = mkOption { default = "fm2382"; };
    rsyncHost = mkOption {
      default = "${cfg.rsyncUser}.rsync.net";
      defaultText = "(output)";
    };
    repo = mkOption {
      default = "${cfg.rsyncUser}@${cfg.rsyncHost}:borg-repos/liam-backup";
      defaultText = "(output)";
    };
    package = mkOption {
      default = pkgs.borgbackup;
      defaultText = "pkgs.borgbackup";
    };
    cmd = mkOption {
      default = lib.getExe cfg.package;
      defaultText = "lib.getExe cfg.package";
    };
    paths = mkOption {
      default = [
        "/var/lib/mail"
        "/var/lib/dovecot"
        "/var/log"
      ];
    };
    keyPath = mkOption {
      default = config.sops.secrets.liam-borg-key.path;
      defaultText = "config.sops.secrets.liam-borg-key.path";
    };
  };
  config = {
    vacu.assertions = lib.singleton {
      assertion =
        (lib.versionAtLeast cfg.package.version "1.4.0")
        && !(lib.versionAtLeast cfg.package.version "1.5.0");
      message = "Only for version 1.4.x";
      fatal = true;
    };

    sops.secrets.liam-borg-key = {
      owner = cfg.user;
    };

    # systemd.tmpfiles.settings."10-auto-borg" = lib.genAttrs cfg.paths (_:
    #   {
    #     # A+ = append to ACLs recursively
    #     "A+" = {
    #       argument = "u:${cfg.user}:r-x";
    #     };
    #   }
    # );
    users.users.${cfg.user} = {
      isSystemUser = true;
      group = cfg.user;
      home = "/var/lib/auto-borg";
    };
    users.groups.${cfg.user} = { };
    systemd.services.auto-borg-gen-key = {
      script = ''
        set -euo pipefail
        ${lib.optionalString config.vacu.underTest "${pkgs.openssh}/bin/ssh -oBatchMode=yes -oStrictHostKeyChecking=accept-new ${cfg.rsyncHost} || true"}
        ${pkgs.openssh}/bin/ssh-keygen -t ed25519 -f "$STATE_DIRECTORY"/id_ed25519 -N ""
      '';
      serviceConfig = commonServiceConfig;
    };
    systemd.services.auto-borg = {
      script = ''
        set -euo pipefail
        # makes a date like 2025-04-15_21-24-29_UTC
        dashed_date="$(date -u '+%F_%H-%M-%S_%Z')"
        archive_name="liam-auto-backup--$dashed_date"
        export BORG_PASSPHRASE="$(cat ${lib.escapeShellArg cfg.keyPath})"
        export BORG_REMOTE_PATH="borg14"
        export BORG_RSH="ssh -i $STATE_DIRECTORY/id_ed25519"
        export BORG_REPO=${lib.escapeShellArg cfg.repo}
        export BORG_CACHE_DIR="$CACHE_DIRECTORY/borg"
        export BORG_CONFIG_DIR="$STATE_DIRECTORY/borg"
        cmd=(
          ${lib.escapeShellArg cfg.cmd}
          create
          --show-rc
          --verbose
          --show-version
          --stats
          --atime
          "::$archive_name"
          ${lib.escapeShellArgs cfg.paths}
        )
        "''${cmd[@]}"
      '';
      serviceConfig = commonServiceConfig;
    };
    systemd.timers.auto-borg = {
      enable = !config.vacu.underTest;
      wantedBy = [ "timers.target" ];
      # run every day at a random time between 3am and 4am, los angeles time
      timerConfig = {
        OnCalendar = "*-*-* 03:00:00 America/Los_Angeles";
        RandomizedDelaySec = 3600;
      };
    };
  };
}
