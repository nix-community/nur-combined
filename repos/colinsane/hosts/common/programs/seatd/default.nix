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
      sandbox.capabilities = [
        "dac_override"  #< TODO: is there no way to get rid of this? (use the `tty` group?)
        # "sys_admin"
        "sys_tty_config"
      ];
      sandbox.tryKeepUsers = true;
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

    systemd.tmpfiles.settings."20-sane-seatd"."${seatdDir}".d = {
      user = "root";
      group = "seat";
      mode = "0770";
    };

    systemd.services.seatd = {
      description = "Seat management daemon";
      documentation = [ "man:seatd(1)" ];

      wantedBy = [ "multi-user.target" ];
      restartIfChanged = false;

      serviceConfig.Type = "simple";
      serviceConfig.ExecStart = "${lib.getExe cfg.package} -g seat";
      serviceConfig.Group = "seat";
      # serviceConfig.AmbientCapabilities = [
      #   "CAP_DAC_OVERRIDE"
      #   "CAP_NET_ADMIN"
      #   "CAP_SYS_ADMIN"
      #   "CAP_SYS_TTY_CONFIG"
      # ];
      serviceConfig.CapabilityBoundingSet = [
        "CAP_DAC_OVERRIDE"  #< needed, to access /dev/tty
        # "CAP_NET_ADMIN"  #< only needed by bwrap
        "CAP_SYS_ADMIN"  #< needed by bwrap/bunpen
        "CAP_SYS_TTY_CONFIG"
      ];
    };
  })
]
