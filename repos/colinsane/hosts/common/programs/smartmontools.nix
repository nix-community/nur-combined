{ config, lib, pkgs, ... }:
let
  cfg = config.sane.programs.smartmontools;
  usePostfix = config.services.postfix.enable;
in
{
  sane.programs.smartmontools = {
    # use like `sudo smartctl /dev/sda -a`
    sandbox.wrapperType = "inplace";  # ships a script in /etc that calls into its bin
    sandbox.autodetectCliPaths = "existing";
    sandbox.capabilities = [ "sys_rawio" ];
    sandbox.tryKeepUsers = true;
  };

  services.smartd = lib.mkIf cfg.enabled {
    enable = true;
    # don't depend on /run/wrappers/bin/sendmail
    notifications.mail.mailer = lib.mkIf usePostfix (lib.getExe' pkgs.postfix "sendmail");
    # see: `man 5 smartd.conf`
    # -a: monitor *all* SMART attributes
    #     equivalent to -H -f -t --log=error --log=selftest --log=selfteststs  -C 197  -U 198
    #     i.e. check SMART health, report failures of "Usage" attributes (rather than "Prefail" attributes), track changes in all attributes,
    #     report increases in logged ATA errors, selftest errors, selftest execution status, and pending sector counts.
    # -o on: enable automatic offline testing  (i.e. the drive firmware will regularly calculate new values for all attributes marked "offline", typically every 4h)
    #        not all drives support this, but the vast majority do
    # -s ..: run self-tests
    #  - format: T/MM/DD/d/HH
    #    - T = test type: L (long self-test ~ 10h), S (short self-test ~ 1m), O (offline data collection ~ 10m)
    #    - MM = month of the year (01 - 12)
    #    - DD = day of the month (01 - 31)
    #    - d = day of the week  (1 - 7)
    #    - HH = hour of the day (00 - 23)
    #  - stagger tests across drives with `:NNN` (NNN hour steps) suffix
    #  - supports regex patterns, like `(A|B)` or `[1-9]`
    #  - never runs more than one test on the same hour,
    #    though when asked to it will prefer to run L > S > C > O.
    #  - if offline at the scheduled test time, it does not attempt to reschedule; that test slot is skipped
    #    unless `smartd` with invoked with `-s` state persistence flag
    #  - `-s L/../../7/04:003`: run Long tests every 7th weekday (Sunday) at 04:00, each drive tested 3hr after the previous
    #  - `-s S/../.././02`: run short tests every day at 02:00
    #  - `-s O/../.././(00|06|12|18)`: run offline data collection every day at 00:00, 06:00, 12:00 and 18:00
    defaults.autodetected = "-a -s (O/../.././(00|06|12|18)|S/../.././02|L/../../7/04:004)";
  };

  services.udev.extraRules = lib.mkIf cfg.enabled ''
    # fix /dev/nvme0, etc, to have same perms as /dev/nvme0n*
    SUBSYSTEM=="nvme" GROUP="disk" MODE="0660"
  '';

  users.users.smartd = lib.mkIf cfg.enabled {
    isSystemUser = true;
    group = "disk";  # for access to /dev/sd*
    extraGroups = [ "postdrop" ];  # for mail delivery
  };
  systemd.services.smartd = lib.mkIf cfg.enabled {
    # hardening options (`systemd-analyze security smartd`)
    serviceConfig.User = "smartd";
    serviceConfig.AmbientCapabilities = [
      "CAP_SYS_ADMIN"  #< only needed for nvme devices
      "CAP_SYS_RAWIO"
    ];
    serviceConfig.CapabilityBoundingSet = [
      "CAP_SYS_ADMIN"  #< only needed for nvme devices
      "CAP_SYS_RAWIO"
    ];
    serviceConfig.NoNewPrivileges = true;
    serviceConfig.DevicePolicy = "closed";
    serviceConfig.DeviceAllow = [
      "block-sd r"
      "char-nvme r"
      # "char-nvme-generic r"
    ];
    serviceConfig.LockPersonality = true;
    serviceConfig.MemoryDenyWriteExecute = true;
    serviceConfig.PrivateIPC = true;
    serviceConfig.PrivateMounts = true;
    serviceConfig.PrivateNetwork = true;
    serviceConfig.PrivateTmp = true;
    serviceConfig.ProcSubset = "pid";
    serviceConfig.ProtectClock = true;
    serviceConfig.ProtectControlGroups = true;
    serviceConfig.ProtectHome = true;
    serviceConfig.ProtectHostname = true;
    serviceConfig.ProtectKernelLogs = true;
    serviceConfig.ProtectKernelModules = true;
    serviceConfig.ProtectKernelTunables = true;
    serviceConfig.ProtectProc = "invisible";
    serviceConfig.ProtectSystem = "strict";
    serviceConfig.RestrictAddressFamilies = [ "AF_UNIX" ];  # AF_UNIX required for systemd to know the service has started
    serviceConfig.RestrictRealtime = true;
    serviceConfig.RestrictSUIDSGID = true;
    serviceConfig.SystemCallArchitectures = "native";
    serviceConfig.SystemCallFilter = [
      "@system-service"
      "~@resources"
      # keep "@privileged" or "@raw-io", since it needs to do that
    ];
    # serviceConfig.RestrictNamespaces = true;
    serviceConfig.ReadWritePaths = lib.mkIf usePostfix [
      "/var/lib/postfix/queue/maildrop"
    ];
    # serviceConfig.PrivateUsers = true;  # can't, because it requires CAP_SYS_RAWIO
  };
}
