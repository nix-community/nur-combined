{ config, lib, pkgs, ... }:
{
  boot.initrd.supportedFilesystems = [ "ext4" "btrfs" "ext2" "ext3" "vfat" ];

  boot.initrd.systemd.emergencyAccess = true;
  boot.initrd.systemd.extraBin = {
    # useful emergency utils
    btrfstune = lib.getExe' pkgs.btrfs-progs "btrfstune";
    cfdisk = lib.getExe' pkgs.util-linux "cfdisk";
    cgdisk = lib.getExe' pkgs.gptfdisk "cgdisk";
    gdisk = lib.getExe' pkgs.gptfdisk "cgdisk";
    lsblk = lib.getExe' pkgs.util-linux "lsblk";
    lscpu = lib.getExe' pkgs.util-linux "lscpu";
    mlable = lib.getExe' pkgs.mtools "mlabel";
    nvme = lib.getExe pkgs.nvme-cli;
    resize2fs = lib.getExe' pkgs.e2fsprogs "resize2fs";
    smartctl = lib.getExe' pkgs.smartmontools "smartctl";
  };

  boot.initrd.availableKernelModules = [
    # "dm_mod"
    "mmc_block"  #< required to load stage2 from SD card (PPP)
    # "mmc_core"
    # "sdhci"
    # "sdhci_pci"
    # "uas"
    "usb_storage"  #< required to load stage2 from SD card (MeLE quieter 4C, rpi400)
  ];

  # ships initrd kernel modules relevant to boot/display for common SBCs
  hardware.enableAllHardware = lib.mkDefault true;

  boot.kernelParams = [
    "boot.shell_on_fail"
    #v experimental full pre-emption for hopefully better call/audio latency on moby.
    # also toggleable at runtime via /sys/kernel/debug/sched/preempt
    # defaults to preempt=voluntary
    # "preempt=full"
  ];
  # other kernelParams:
  # - "boot.trace"
  # - "systemd.log_level=debug"
  # - "systemd.log_target=console"
  # - "boot.debug1": drop to shell immediately
  # - "boot.debug1devices": drop to shell after creating device nodes
  # - "boot.debug1mounts": drop to shell after mounting file systems
  # - "module_blacklist=abc,def,...": prevent kernel modules `abc`, `def`, `...` from being loaded (automatically OR manually)

  # moby has to run recent kernels (defined elsewhere).
  # meanwhile, kernel variation plays some minor role in things like sandboxing (landlock) and capabilities.
  # - as of 2024/08/xx, my boot fails on 6.6, but works on 6.9 and (probably; recently) 6.8.
  # simpler to keep near the latest kernel on all devices,
  # and also makes certain that any weird system-level bugs i see aren't likely to be stale kernel bugs.
  boot.kernelPackages = let
    base = pkgs.linux_latest;
    # base = pkgs.linux_testing;
    kernel =
      # `linux.override { ... }` accepts any argument names and silently ignores unrecognized options:
      # assert that we're naming options that are actually processed by `buildLinux`.
      assert base.override { autoModules = true; } != base.override { autoModules = false; };
      assert base.override { preferBuiltin = true; } != base.override { preferBuiltin = false; };
      base.override {
        autoModules = true;
        preferBuiltin = false;
      };
  in
    lib.mkDefault (pkgs.linuxPackagesFor kernel);

  # nixpkgs.hostPlatform.linux-kernel = (lib.systems.elaborate config.nixpkgs.hostPlatform.system).linux-kernel // {
  #   # explicitly ignore nixpkgs' extraConfig and preferBuiltin options
  #   autoModules = true;
  #   # build all features as modules where possible, especially because
  #   # 1. some bootloaders fail on large payloads and this allows the kernel/initrd to be smaller.
  #   # 2. building as module means i can override that module very cheaply as i develop.
  #   preferBuiltin = false;
  #   # `target` support matrix:
  #   # Image:     aarch64:yes (nixpkgs default)       x86_64:no
  #   # Image.gz:  aarch64:yes, if capable bootloader  x86_64:no
  #   # zImage     aarch64:no                          x86_64:yes
  #   # bzImage    aarch64:no                          x86_64:yes (nixpkgs default)
  #   # vmlinux    aarch64:?                           x86_64:no?
  #   # vmlinuz    aarch64:?                           x86_64:?
  #   # uImage     aarch64:bootloader?                 x86_64:probably not
  #   # # target = if system == "x86_64-linux" then "bzImage" else "Image";
  # };
  # # patch `buildPlatform.linux-kernel` in the same manner:
  # # even though i don't use the buildPlatform's kernel, if nixpkgs were to see they're different
  # # it would force everything down the (expensive) cross-compilation path.
  # nixpkgs.buildPlatform.linux-kernel = (lib.systems.elaborate config.nixpkgs.system).linux-kernel // {
  #   autoModules = true;
  #   preferBuiltin = false;
  # };

  # hack in the `boot.shell_on_fail` arg since that doesn't always seem to work.
  # boot.initrd.preFailCommands = "allowShell=1";

  # default: 4 (warn). 7 is debug
  boot.consoleLogLevel = 7;

  boot.loader.grub.enable = lib.mkDefault false;
  boot.loader.systemd-boot.enable = lib.mkDefault true;
  boot.loader.systemd-boot.configurationLimit = lib.mkDefault 20;
  boot.loader.systemd-boot.edk2-uefi-shell.enable = lib.mkDefault true;
  boot.loader.systemd-boot.memtest86.enable = lib.mkDefault
    (lib.meta.availableOn pkgs.stdenv.hostPlatform pkgs.memtest86plus);

  warnings = lib.optionals (config.boot.loader.systemd-boot.enable && config.hardware.deviceTree.package != null && config.hardware.deviceTree.name == null) [
    ("systemd-boot enabled on a device-tree-enabled system but without configuring hardware.deviceTree.name: " +
    "system will boot against the platform firmware's .dtb instead of the kernel's more up-to-date dtb")
  ];

  hardware.enableAllFirmware = lib.mkDefault true;  # firmware with licenses that don't allow for redistribution. fuck lawyers, fuck IP, give me the goddamn firmware.
  # hardware.enableRedistributableFirmware = true;  # proprietary but free-to-distribute firmware (extraneous to `enableAllFirmware` option)

  # default is 252274, which is too low particularly for servo.
  # manifests as spurious "No space left on device" when trying to install watches,
  # e.g. in dyn-dns by `systemctl start dyn-dns-watcher.path`.
  # see: <https://askubuntu.com/questions/828779/failed-to-add-run-systemd-ask-password-to-directory-watch-no-space-left-on-dev>
  boot.kernel.sysctl."fs.inotify.max_user_watches" = 4194304;
  boot.kernel.sysctl."fs.inotify.max_user_instances" = 4194304;
}
