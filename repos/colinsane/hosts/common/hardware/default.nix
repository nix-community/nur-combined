{ config, lib, pkgs, ... }:

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

  # hack in the `boot.shell_on_fail` arg since that doesn't always seem to work.
  boot.initrd.preFailCommands = "allowShell=1";

  # default: 4 (warn). 7 is debug
  boot.consoleLogLevel = 7;

  boot.loader.grub.enable = lib.mkDefault false;
  boot.loader.generic-extlinux-compatible.enable = lib.mkDefault true;

  # non-free firmware
  hardware.enableRedistributableFirmware = true;

  # default is 252274, which is too low particularly for servo.
  # manifests as spurious "No space left on device" when trying to install watches,
  # e.g. in dyn-dns by `systemctl start dyn-dns-watcher.path`.
  # see: <https://askubuntu.com/questions/828779/failed-to-add-run-systemd-ask-password-to-directory-watch-no-space-left-on-dev>
  boot.kernel.sysctl."fs.inotify.max_user_watches" = 1048576;

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
    # see: `man logind.conf`
    # don’t shutdown when power button is short-pressed (commonly done an accident, or by cats).
    #   but do on long-press: useful to gracefully power-off server.
    HandlePowerKey=lock
    HandlePowerKeyLongPress=poweroff
    HandleLidSwitch=lock
  '';

  # some packages build only if binfmt *isn't* present
  nix.settings.system-features = lib.mkIf (config.boot.binfmt.emulatedSystems == []) [
    "no-binfmt"
  ];

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
