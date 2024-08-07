{ config, lib, pkgs, ... }:
let
  cfg = config.sane.programs.seatd;
  seatdDir = "/run/seatd";
  seatdSock = "${seatdDir}/seatd.sock";
in
lib.mkMerge [
  {
    sane.programs.seatd = {
      packageUnwrapped = pkgs.seatd.overrideAttrs (base: {
        # patch so seatd places its socket in a place that's easier to sandbox
        mesonFlags = base.mesonFlags ++ [
          "-Ddefaultpath=${seatdSock}"
        ];
      });
      sandbox.method = "bwrap";
      sandbox.capabilities = [
        # "chown"
        "dac_override"  #< TODO: is there no way to get rid of this? (use the `tty` group?)
        # "sys_admin"
        "sys_tty_config"
      ];
      sandbox.isolateUsers = false;
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
        seatdDir
        # "/sys"
      ];
      env.SEATD_SOCK = seatdSock;  #< client side configuration (i.e. tells sway where to look)
    };
  }
  (lib.mkIf cfg.enabled {
    users.groups.seat = {};

    sane.fs."${seatdDir}".dir.acl = {
      user = "root";
      group = "seat";
      mode = "0770";
    };

    systemd.services.seatd = {
      description = "Seat management daemon";
      documentation = [ "man:seatd(1)" ];

      after = [ config.sane.fs."${seatdDir}".unit ];
      wants = [ config.sane.fs."${seatdDir}".unit ];
      wantedBy = [ "multi-user.target" ];
      restartIfChanged = false;

      serviceConfig.Type = "simple";
      serviceConfig.ExecStart = "${cfg.package}/bin/seatd -g seat";
      serviceConfig.Group = "seat";
      # serviceConfig.AmbientCapabilities = [
      #   "CAP_DAC_OVERRIDE"
      #   "CAP_NET_ADMIN"
      #   "CAP_SYS_ADMIN"
      #   "CAP_SYS_TTY_CONFIG"
      # ];
      serviceConfig.CapabilityBoundingSet = [
        # TODO: these can probably be reduced if i switch to landlock for sandboxing,
        # or run as a user other than root
        # "CAP_CHOWN"
        "CAP_DAC_OVERRIDE"  #< needed, to access /dev/tty
        "CAP_NET_ADMIN"  #< needed by bwrap, for some reason??
        "CAP_SYS_ADMIN"  #< needed by bwrap
        "CAP_SYS_TTY_CONFIG"
      ];
    };
  })
]
