{lib, ...}: let
  swapfileSizeMiB = 40 * 1024;
in {
  # One swap device only: hibernation writes its image to a single swap area, and the
  # old 8.8 GB partition ran out (ENOSPC) under Gradle + Baloo load, which aborted
  # hibernation and let the kernel OOM-kill apps. 40 GB holds a full 32 GB RAM image.
  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = swapfileSizeMiB;
    }
  ];

  # No boot.resumeDevice / resume_offset: systemd records the swapfile's device and
  # offset in the HibernateLocation EFI variable, and the (systemd) initrd resumes from it.

  # zswap compresses in RAM in front of the swapfile and evicts cold pages to it. No
  # zram: it has no eviction, so cold pages would fill it while hot ones hit the disk.
  boot.kernelParams = ["zswap.enabled=1" "zswap.shrinker_enabled=1"];

  # 10 starved the file cache and let anonymous pages pile up until swap was full.
  # mkForce: cachyos-settings-nix's sysctl area sets 150 when enabled.
  boot.kernel.sysctl."vm.swappiness" = lib.mkForce 60;
}
