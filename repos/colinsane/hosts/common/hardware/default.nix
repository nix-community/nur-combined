{ lib, pkgs, ... }:

{
  imports = [
    ./x86_64.nix
  ];

  boot.initrd.supportedFilesystems = [ "ext4" "btrfs" "ext2" "ext3" "vfat" ];
  # useful emergency utils
  boot.initrd.extraUtilsCommands = ''
    copy_bin_and_libs ${pkgs.btrfs-progs}/bin/btrfstune
    copy_bin_and_libs ${pkgs.util-linux}/bin/{cfdisk,lsblk,lscpu}
    copy_bin_and_libs ${pkgs.gptfdisk}/bin/{cgdisk,gdisk}
    copy_bin_and_libs ${pkgs.smartmontools}/bin/smartctl
    copy_bin_and_libs ${pkgs.nvme-cli}/bin/nvme
    copy_bin_and_libs ${pkgs.e2fsprogs}/bin/resize2fs
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

  # hack in the `boot.shell_on_fail` arg since that doesn't always seem to work.
  boot.initrd.preFailCommands = "allowShell=1";

  # default: 4 (warn). 7 is debug
  boot.consoleLogLevel = 7;

  boot.loader.grub.enable = lib.mkDefault false;
  boot.loader.generic-extlinux-compatible.enable = lib.mkDefault true;

  # non-free firmware
  hardware.enableRedistributableFirmware = true;

  # powertop will default to putting USB devices -- including HID -- to sleep after TWO SECONDS
  powerManagement.powertop.enable = false;
  # linux CPU governor: <https://www.kernel.org/doc/Documentation/cpu-freq/governors.txt>
  # - options:
  #   - "powersave" => force CPU to always run at lowest supported frequency
  #   - "performance" => force CPU to always run at highest frequency
  #   - "ondemand" => adjust frequency based on load
  #   - "conservative"  (ondemand but slower to adjust)
  #   - "schedutil"
  #   - "userspace"
  # - not all options are available for all platforms
  #   - intel (intel_pstate) appears to manage scaling w/o intervention/control from the OS.
  #   - AMD (acpi-cpufreq) appears to manage scaling via the OS *or* HW. but the ondemand defaults never put it to max hardware frequency.
  #   - qualcomm (cpufreq-dt) appears to manage scaling *only* via the OS. ondemand governor exercises the full range.
  # - query details with `sudo cpupower frequency-info`
  powerManagement.cpuFreqGovernor = "ondemand";

  services.logind.extraConfig = ''
    # don’t shutdown when power button is short-pressed
    HandlePowerKey=ignore
  '';

  # services.snapper.configs = {
  #   root = {
  #     subvolume = "/";
  #     extraConfig = {
  #       ALLOW_USERS = "colin";
  #     };
  #   };
  # };
  # services.snapper.snapshotInterval = "daily";
}
