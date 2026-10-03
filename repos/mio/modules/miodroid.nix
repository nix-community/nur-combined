{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.virtualisation.miodroid;
  kCfg = config.lib.kernelConfig;
  miodroidGbinderConf = pkgs.writeText "miodroid.conf" ''
    [Protocol]
    /dev/binder = aidl2
    /dev/vndbinder = aidl2
    /dev/hwbinder = hidl

    [ServiceManager]
    /dev/binder = aidl2
    /dev/vndbinder = aidl2
    /dev/hwbinder = hidl
  '';
in
{
  options.virtualisation.miodroid = {
    enable = lib.mkEnableOption "Miodroid";
    package = lib.mkPackageOption pkgs "miodroid" { };
    rootlessUser = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = "alice";
      description = ''
        Prepare unprivileged LXC networking and subordinate IDs for this user.
        The Home Manager rootless module remains experimental and does not yet
        provide all mounts and device setup required by Miodroid.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = lib.singleton {
      assertion = lib.versionAtLeast (lib.getVersion config.boot.kernelPackages.kernel) "4.18";
      message = "Miodroid needs user namespace support to work properly";
    };

    system.requiredKernelConfig = [
      (kCfg.isEnabled "ANDROID_BINDER_IPC")
      (kCfg.isEnabled "ANDROID_BINDERFS")
      (kCfg.isEnabled "MEMFD_CREATE")
    ];

    boot.kernelParams = [ "psi=1" ];

    environment.etc."gbinder.d/miodroid.conf".source = miodroidGbinderConf;
    environment.systemPackages = [ cfg.package ];

    networking.firewall.trustedInterfaces = [ "miodroid0" ];

    virtualisation.lxc = {
      enable = true;
      unprivilegedContainers = cfg.rootlessUser != null;
      usernetConfig = lib.mkIf (cfg.rootlessUser != null) ''
        ${cfg.rootlessUser} veth lxcbr0 10
      '';
    };

    users.users = lib.mkIf (cfg.rootlessUser != null) {
      ${cfg.rootlessUser} = {
        autoSubUidGidRange = lib.mkDefault true;
        extraGroups = lib.mkAfter [ "lxc-user" ];
      };
    };

    systemd.services.miodroid-container = {
      description = "Miodroid Container";
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        Type = "dbus";
        UMask = "0022";
        ExecStart = "${cfg.package}/bin/miodroid container start";
        BusName = "id.miodro.Container";
      };
    };

    systemd.tmpfiles.rules = [
      "d /var/lib/misc 0755 root root -"
    ];

    services.dbus.packages = [ cfg.package ];
  };
}
