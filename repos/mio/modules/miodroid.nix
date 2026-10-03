{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.virtualisation.miodroid;
  kCfg = config.lib.kernelConfig;
  rootlessUser = if cfg.rootlessUser == null then "root" else cfg.rootlessUser;
  rootlessHelper = pkgs.writeShellScript "miodroid-rootless-helper" ''
    set -eu

    user=${lib.escapeShellArg rootlessUser}
    uid="$(id -u "$user")"
    gid="$(id -g "$user")"

    ${pkgs.kmod}/bin/modprobe binder_linux
    ${pkgs.coreutils}/bin/install -d -m 0755 /dev/binderfs
    if ! ${pkgs.util-linux}/bin/mountpoint -q /dev/binderfs; then
      ${pkgs.util-linux}/bin/mount -t binder binder /dev/binderfs
    fi

    for node in binder vndbinder hwbinder; do
      test -e "/dev/binderfs/$node"
      ${pkgs.coreutils}/bin/chmod 0660 "/dev/binderfs/$node"
      ${pkgs.coreutils}/bin/chown "$uid:$gid" "/dev/binderfs/$node"
      ${pkgs.coreutils}/bin/ln -sfn "/dev/binderfs/$node" "/dev/$node"
    done

    test -x ${pkgs.lxc}/bin/lxc-start
    test -x ${pkgs.lxc}/bin/lxc-user-nic
  '';
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
    boot.kernelModules = lib.mkIf (cfg.rootlessUser != null) [ "binder_linux" ];
    boot.extraModprobeConfig = lib.mkIf (cfg.rootlessUser != null) ''
      options binder_linux devices=binder,vndbinder,hwbinder
    '';

    services.udev.extraRules = lib.mkIf (cfg.rootlessUser != null) ''
      KERNEL=="binder", MODE="0666"
      KERNEL=="vndbinder", MODE="0666"
      KERNEL=="hwbinder", MODE="0666"
    '';

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

    systemd.services = {
      "miodroid-rootless-helper-${rootlessUser}" = lib.mkIf (cfg.rootlessUser != null) {
        description = "Miodroid rootless host preparation";
        wantedBy = [ "multi-user.target" ];
        before = [ "miodroid-container.service" ];
        serviceConfig = {
          Type = "oneshot";
          ExecStart = rootlessHelper;
          RemainAfterExit = true;
        };
      };

      miodroid-container = {
        description = "Miodroid Container";
        wantedBy = [ "multi-user.target" ];

        serviceConfig = {
          Type = "dbus";
          UMask = "0022";
          ExecStart = "${cfg.package}/bin/miodroid container start";
          BusName = "id.miodro.Container";
        };
      };
    };

    systemd.tmpfiles.rules = [
      "d /var/lib/misc 0755 root root -"
    ];

    services.dbus.packages = [ cfg.package ];
  };
}
