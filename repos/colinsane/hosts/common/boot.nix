{ lib, pkgs, ... }:
{
  boot.initrd.supportedFilesystems = [ "ext4" "btrfs" "ext2" "ext3" "vfat" ];
  # useful emergency utils
  boot.initrd.extraUtilsCommands = ''
    copy_bin_and_libs ${pkgs.btrfs-progs}/bin/btrfstune
    copy_bin_and_libs ${pkgs.util-linux}/bin/{cfdisk,lsblk,lscpu}
    copy_bin_and_libs ${pkgs.gptfdisk}/bin/{cgdisk,gdisk}
    copy_bin_and_libs ${pkgs.smartmontools}/bin/smartctl
    copy_bin_and_libs ${pkgs.e2fsprogs}/bin/resize2fs
  '' + lib.optionalString pkgs.stdenv.hostPlatform.isx86_64 ''
    copy_bin_and_libs ${pkgs.nvme-cli}/bin/nvme  # doesn't cross compile
  '';
  boot.kernelParams = [
    "boot.shell_on_fail"
    #v experimental full pre-emption for hopefully better call/audio latency on moby.
    # also toggleable at runtime via /sys/kernel/debug/sched/preempt
    # defaults to preempt=voluntary
    # "preempt=full"
  ];
  # other kernelParams:
  #   "boot.trace"
  #   "systemd.log_level=debug"
  #   "systemd.log_target=console"

  # moby has to run recent kernels (defined elsewhere).
  # meanwhile, kernel variation plays some minor role in things like sandboxing (landlock) and capabilities.
  # - as of 2024/08/xx, my boot fails on 6.6, but works on 6.9 and (probably; recently) 6.8.
  # simpler to keep near the latest kernel on all devices,
  # and also makes certain that any weird system-level bugs i see aren't likely to be stale kernel bugs.
  # servo needs zfs though, which doesn't support every kernel.
  #
  # further, `zfs.latestCompatibleLinuxPackage` ocassionally _downgrades_. e.g. when 6.8 EOL'd, it went back to 6.6.
  # therefore, we have to use `zfs_unstable` (!!)
  boot.kernelPackages = lib.mkDefault pkgs.zfs_unstable.latestCompatibleLinuxPackages;

  # hack in the `boot.shell_on_fail` arg since that doesn't always seem to work.
  boot.initrd.preFailCommands = "allowShell=1";

  # default: 4 (warn). 7 is debug
  boot.consoleLogLevel = 7;

  boot.loader.grub.enable = lib.mkDefault false;
  boot.loader.generic-extlinux-compatible.enable = lib.mkDefault true;

  hardware.enableAllFirmware = true;  # firmware with licenses that don't allow for redistribution. fuck lawyers, fuck IP, give me the goddamn firmware.
  # hardware.enableRedistributableFirmware = true;  # proprietary but free-to-distribute firmware (extraneous to `enableAllFirmware` option)

  # default is 252274, which is too low particularly for servo.
  # manifests as spurious "No space left on device" when trying to install watches,
  # e.g. in dyn-dns by `systemctl start dyn-dns-watcher.path`.
  # see: <https://askubuntu.com/questions/828779/failed-to-add-run-systemd-ask-password-to-directory-watch-no-space-left-on-dev>
  boot.kernel.sysctl."fs.inotify.max_user_watches" = 4194304;
  boot.kernel.sysctl."fs.inotify.max_user_instances" = 4194304;
}
