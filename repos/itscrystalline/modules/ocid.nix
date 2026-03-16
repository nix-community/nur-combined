{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.ocid;
  pkg = cfg.package;
in {
  _class = "nixos";

  options.services.ocid = {
    enable = lib.mkEnableOption "Oracle Cloud Infrastructure utilities daemon (ocid)";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.callPackage ../pkgs/oci-utils {};
      defaultText = lib.literalExpression "pkgs.callPackage ../pkgs/oci-utils {}";
      description = "The oci-utils package to use.";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.ocid = {
      description = "Oracle Cloud Infrastructure utilities daemon";
      # iscsid is used for iSCSI volume attachment scanning
      after = ["iscsid.service"];
      wants = ["iscsid.service"];
      wantedBy = ["multi-user.target"];

      serviceConfig = {
        Type = "notify";
        NotifyAccess = "all";

        ExecStart = "${pkg}/libexec/oci-utils/ocid --no-daemon";

        Restart = "always";
        TimeoutStartSec = 300; # ocid does a lot of scanning on startup
        TimeoutStopSec = 5;

        # ocid writes its PID and state to /run/ocid/
        RuntimeDirectory = "ocid";
        RuntimeDirectoryMode = "0755";

        # Log to journal via stdout/stderr (upstream used syslog, journal is the NixOS equivalent)
        StandardOutput = "journal";
        StandardError = "journal";

        # ocid needs root to manage iSCSI and VNIC configuration
        User = "root";
        Group = "root";

        # Light hardening — ocid modifies network/iscsi config, so we keep it minimal
        ProtectSystem = "full";
        ProtectHome = true;
        PrivateTmp = true;
        # ocid does not need to gain new privileges
        NoNewPrivileges = true;
      };
    };
  };
}
