{ config, lib, pkgs, ... }:
{
  boot.initrd.supportedFilesystems = [ "ext4" "btrfs" "ext2" "ext3" "vfat" ];
  # useful emergency utils
  boot.initrd.extraUtilsCommands = ''
    copy_bin_and_libs ${lib.getExe' pkgs.btrfs-progs "btrfstune"}
    copy_bin_and_libs ${lib.getExe' pkgs.e2fsprogs "resize2fs"}
    copy_bin_and_libs ${lib.getExe' pkgs.gptfdisk "{cgdisk,gdisk}"}
    copy_bin_and_libs ${lib.getExe' pkgs.mtools "mlabel"}
    copy_bin_and_libs ${lib.getExe pkgs.nvme-cli}
    copy_bin_and_libs ${lib.getExe' pkgs.smartmontools "smartctl"}
    copy_bin_and_libs ${lib.getExe' pkgs.util-linux "{cfdisk,lsblk,lscpu}"}
  '';

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
  boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;
  # boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_testing;

  # hack in the `boot.shell_on_fail` arg since that doesn't always seem to work.
  boot.initrd.preFailCommands = "allowShell=1";

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

  hardware.enableAllFirmware = true;  # firmware with licenses that don't allow for redistribution. fuck lawyers, fuck IP, give me the goddamn firmware.
  # hardware.enableRedistributableFirmware = true;  # proprietary but free-to-distribute firmware (extraneous to `enableAllFirmware` option)

  # default is 252274, which is too low particularly for servo.
  # manifests as spurious "No space left on device" when trying to install watches,
  # e.g. in dyn-dns by `systemctl start dyn-dns-watcher.path`.
  # see: <https://askubuntu.com/questions/828779/failed-to-add-run-systemd-ask-password-to-directory-watch-no-space-left-on-dev>
  boot.kernel.sysctl."fs.inotify.max_user_watches" = 4194304;
  boot.kernel.sysctl."fs.inotify.max_user_instances" = 4194304;
}
