{ config, lib, ... }:
let
  cfg = config.sane.programs.seatd;
in
lib.mkMerge [
  {
    sane.programs.seatd = {
      sandbox.method = "bwrap";
      sandbox.capabilities = [
        "sys_tty_config" "sys_admin"
        "chown"
        "dac_override"  #< TODO: is there no way to get rid of this?
      ];
      sandbox.extraPaths = [
        "/dev"  #< TODO: this can be removed if i have seatd restart on client error such that seatd can discover devices as they appear
        # "/dev/dri"
        # # "/dev/drm_dp_aux0"
        # # "/dev/drm_dp_aux1"
        # # "/dev/drm_dp_aux2"
        # # "/dev/fb0"
        # "/dev/input"
        # # "/dev/uinput"
        # "/dev/tty0"
        # "/dev/tty1"
        # "/proc"
        "/run"  #< TODO: confine this to some subdirectory
        # "/sys"
      ];
    };
  }
  (lib.mkIf cfg.enabled {
    users.groups.seat = {};

    # TODO: /run/seatd.sock location can be configured, but only via compile-time flag
    systemd.services.seatd = {
      description = "Seat management daemon";
      documentation = [ "man:seatd(1)" ];

      wantedBy = [ "multi-user.target" ];
      restartIfChanged = false;

      serviceConfig = {
        Type = "simple";
        ExecStart = "${cfg.package}/bin/seatd -g seat";
        Group = "seat";
        # AmbientCapabilities = [ "CAP_SYS_TTY_CONFIG" "CAP_SYS_ADMIN" ];
      };
    };
  })
]
