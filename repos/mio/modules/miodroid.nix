{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.virtualisation.miodroid;
  rootlessCfg = config.virtualisation.miodroid-rootless;
  miodroidEnabled = cfg.enable || rootlessCfg.enable;
  miodroidPackage = if rootlessCfg.enable then rootlessCfg.package else cfg.package;
  imagePackage =
    if rootlessCfg.enable && rootlessCfg.imagePackage != null then
      rootlessCfg.imagePackage
    else
      cfg.imagePackage;
  kCfg = config.lib.kernelConfig;
  rootlessHelper = pkgs.writeShellScript "miodroid-rootless-helper" ''
    set -eu

    if ${pkgs.coreutils}/bin/test -e /sys/module/binder_linux ||
      ${pkgs.gzip}/bin/gzip -cd /proc/config.gz |
      ${pkgs.gnugrep}/bin/grep -q 'CONFIG_ANDROID_BINDER_IPC=y'; then
      :
    else
      ${pkgs.kmod}/bin/modprobe binder_linux
    fi
    ${pkgs.coreutils}/bin/install -d -m 0755 /dev/binderfs
    if ! ${pkgs.util-linux}/bin/mountpoint -q /dev/binderfs; then
      ${pkgs.util-linux}/bin/mount -t binder binder /dev/binderfs
    fi

    for node in binder vndbinder hwbinder; do
      test -e "/dev/binderfs/$node"
      ${pkgs.coreutils}/bin/chmod 0660 "/dev/binderfs/$node"
      ${pkgs.coreutils}/bin/chown root:${rootlessCfg.group} "/dev/binderfs/$node"
      ${pkgs.coreutils}/bin/ln -sfn "/dev/binderfs/$node" "/dev/$node"
    done

    test -x ${pkgs.lxc}/bin/lxc-start
    test -x ${pkgs.lxc}/libexec/lxc/lxc-user-nic
  '';
  rootlessDbusService = pkgs.writeTextFile {
    name = "miodroid-rootless-dbus-service";
    destination = "/share/dbus-1/services/id.miodro.Container.service";
    text = ''
      [D-BUS Service]
      Name=id.miodro.Container
      Exec=${miodroidPackage}/bin/miodroid container start
    '';
  };
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
    imagePackage = lib.mkOption {
      type = lib.types.nullOr lib.types.package;
      default = null;
      example = lib.literalExpression "pkgs.miodroid-images.a16";
      description = ''
        Declarative system.img and vendor.img bundle to install before
        initialization. When null, miodroid uses its normal OTA workflow.
      '';
    };
  };
  options.virtualisation.miodroid-rootless = {
    enable = lib.mkEnableOption "experimental rootless Miodroid support";
    package = lib.mkPackageOption pkgs "miodroid" { };
    imagePackage = lib.mkOption {
      type = lib.types.nullOr lib.types.package;
      default = null;
      example = lib.literalExpression "pkgs.miodroid-images.a16";
      description = ''
        Declarative system.img and vendor.img bundle to install before
        initialization. When null, miodroid uses its normal OTA workflow.
      '';
    };
    group = lib.mkOption {
      type = lib.types.str;
      default = "miodroid";
      example = "android";
      description = ''
        Unix group allowed to run rootless Miodroid containers. Add each
        account to this group and to lxc-user, and enable
        users.users.<name>.autoSubUidGidRange = true for every account.
      '';
    };
  };

  config = lib.mkIf miodroidEnabled {
    assertions = [
      {
        assertion = lib.versionAtLeast (lib.getVersion config.boot.kernelPackages.kernel) "4.18";
        message = "Miodroid needs user namespace support to work properly";
      }
    ];

    system.requiredKernelConfig = [
      (kCfg.isEnabled "ANDROID_BINDER_IPC")
      (kCfg.isEnabled "ANDROID_BINDERFS")
      (kCfg.isEnabled "MEMFD_CREATE")
    ];

    boot.kernelParams = [ "psi=1" ];
    boot.extraModprobeConfig = lib.mkIf rootlessCfg.enable ''
      options binder_linux devices=binder,vndbinder,hwbinder
    '';

    services.udev.extraRules = lib.mkIf rootlessCfg.enable ''
      KERNEL=="binder", GROUP="${rootlessCfg.group}", MODE="0660"
      KERNEL=="vndbinder", GROUP="${rootlessCfg.group}", MODE="0660"
      KERNEL=="hwbinder", GROUP="${rootlessCfg.group}", MODE="0660"
    '';

    environment.etc."gbinder.d/miodroid.conf".source = miodroidGbinderConf;
    environment.systemPackages = [
      miodroidPackage
    ]
    ++ lib.optional rootlessCfg.enable rootlessDbusService;
    environment.etc."miodroid-extra/images" = lib.mkIf (imagePackage != null) {
      source = imagePackage;
    };

    networking.firewall.trustedInterfaces = lib.mkIf cfg.enable [ "miodroid0" ];

    virtualisation.lxc = {
      enable = true;
      unprivilegedContainers = rootlessCfg.enable;
      usernetConfig = lib.mkIf rootlessCfg.enable "@${rootlessCfg.group} veth lxcbr0 10\n";
    };

    users.groups.${rootlessCfg.group} = lib.mkIf rootlessCfg.enable { };

    systemd.services = {
      miodroid-rootless-helper = lib.mkIf rootlessCfg.enable {
        description = "Miodroid rootless host preparation";
        wantedBy = [ "multi-user.target" ];
        after = [
          "systemd-modules-load.service"
          "systemd-udev-settle.service"
        ];
        serviceConfig = {
          Type = "oneshot";
          ExecStart = rootlessHelper;
          RemainAfterExit = true;
        };
      };

      miodroid-container = lib.mkIf cfg.enable {
        description = "Miodroid Container";
        wantedBy = [ "multi-user.target" ];

        serviceConfig = {
          Type = "dbus";
          UMask = "0022";
          ExecStart = "${miodroidPackage}/bin/miodroid container start";
          BusName = "id.miodro.Container";
        };
      };
    };

    systemd.tmpfiles.rules = [
      "d /var/lib/misc 0755 root root -"
    ];

    services.dbus.packages = [ miodroidPackage ];
  };
}
