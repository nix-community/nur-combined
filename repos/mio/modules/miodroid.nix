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
  # Extra environment for the rootless container: the image strategy is a
  # property of the process that starts it, so it travels in the environment of
  # whichever unit starts it (see the home-manager module).
  rootlessStrategyEnv = lib.optionalString (
    rootlessCfg.enable && rootlessCfg.imageStrategy == "overlay"
  ) " MIODROID_ROOTLESS_OVERLAY=1";
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
      Exec=${pkgs.bash}/bin/bash -c "exec env MIODROID_ROOTLESS=1 MIODROID_WORK=''${XDG_DATA_HOME:-$HOME/.local/share}/miodroid${rootlessStrategyEnv} ${miodroidPackage}/bin/miodroid --details-to-stdout container start"
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
      default = pkgs.callPackage ../by-name/mi/miodroid/robotnix-image.nix {};
      example = lib.literalExpression "pkgs.miodroid-images.a16";
      description = ''
        Declarative system.img and vendor.img bundle to install before
        initialization. Defaults to our custom Robotnix LineageOS build.
        When null, miodroid uses its normal OTA workflow.
      '';
    };
  };
  options.virtualisation.miodroid-rootless = {
    enable = lib.mkEnableOption "experimental rootless Miodroid support";
    package = lib.mkPackageOption pkgs "miodroid" { };
    imagePackage = lib.mkOption {
      type = lib.types.nullOr lib.types.package;
      default = pkgs.callPackage ../by-name/mi/miodroid/robotnix-image.nix {};
      example = lib.literalExpression "pkgs.miodroid-images.a16";
      description = ''
        Declarative system.img and vendor.img bundle to install before
        initialization. Defaults to our custom Robotnix LineageOS build.
        When null, miodroid uses its normal OTA workflow.
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
    hostBinderfs = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Prepare binderfs on the host: mount it, hand its device nodes to
        {option}`group` and keep them writable through a root oneshot service.

        Off by default, because a user namespace may mount binderfs itself,
        which is what lets the container bring up its own binder devices
        without any host preparation, group membership or device nodes. Turn
        this on if in-container binderfs does not work on your kernel (it is
        how this module used to do it, and it is still what makes the *rootful*
        container's binder nodes).
      '';
    };
    imageStrategy = lib.mkOption {
      type = lib.types.enum [
        "grow"
        "overlay"
      ];
      default = "grow";
      description = ''
        How the rootless container gets a writable Android system and vendor
        image.

        - `grow` (default): copy each OTA image into the work directory, fsck
          it, grow it by 1 GiB and mount it read-write. Self-contained, but the
          images are copied and modified and Android writes into the image.
        - `overlay`: mount the images read-only and absorb the writes in a
          host-side fuse-overlayfs overlay, the way rootful Miodroid and Valve's
          Lepton do. No image growth and no per-start fsck, and the OTA images
          stay pristine.

        `overlay` is the better model and is meant to become the default once
        it has seen some mileage; keep this in sync with
        {option}`programs.miodroid-rootless.imageStrategy` in the home-manager
        module, which starts the same container.
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
    # Rootless mode needs the binder driver available to mount its own
    # binderfs from inside the container.  Loading it here is what replaced the
    # helper's "modprobe binder_linux": NixOS treats a module that is missing
    # (because it is built in) as a non-fatal failure.
    boot.kernelModules = lib.mkIf rootlessCfg.enable [ "binder_linux" ];
    boot.extraModprobeConfig = lib.mkIf rootlessCfg.enable ''
      options binder_linux devices=binder,vndbinder,hwbinder
    '';

    services.udev.extraRules = lib.mkIf (rootlessCfg.enable && rootlessCfg.hostBinderfs) ''
      KERNEL=="binder", GROUP="${rootlessCfg.group}", MODE="0660"
      KERNEL=="vndbinder", GROUP="${rootlessCfg.group}", MODE="0660"
      KERNEL=="hwbinder", GROUP="${rootlessCfg.group}", MODE="0660"
    '';

    environment.etc."gbinder.d/miodroid.conf".source = miodroidGbinderConf;

    # Rootless mode mounts the images and the overlays with fuse2fs and
    # fuse-overlayfs as the invoking user, so it needs both the setuid
    # fusermount3 wrappers and user_allow_other in /etc/fuse.conf.  Setting
    # userAllowOther alone does nothing: nixpkgs writes fuse.conf and the
    # wrappers only when programs.fuse.enable is on.
    programs.fuse = lib.mkIf rootlessCfg.enable {
      enable = true;
      userAllowOther = true;
    };
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
      # Unprivileged containers bring lxc-net (the lxcbr0 bridge with NAT and
      # dnsmasq) and the setuid lxc-user-nic helper that rootless Miodroid
      # needs.  mkDefault so a user can still turn them off deliberately.
      unprivilegedContainers = lib.mkIf rootlessCfg.enable (lib.mkDefault true);
      usernetConfig = lib.mkIf rootlessCfg.enable "@${rootlessCfg.group} veth lxcbr0 10\n";
    };

    users.groups.${rootlessCfg.group} = lib.mkIf rootlessCfg.enable { };

    systemd.services = {
      miodroid-rootless-helper = lib.mkIf (rootlessCfg.enable && rootlessCfg.hostBinderfs) {
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
