{ ... }:

# stolen from https://nixos.wiki/wiki/LVM

{
  boot.initrd.kernelModules = [
    "dm-snapshot" # when you are using snapshots
    "dm-raid" # e.g. when you are configuring raid1 via: `lvconvert -m1 /dev/pool/home`
    "dm-cache-default" # when using volumes set up with lvmcache
  ];

  services.lvm.boot.thin.enable = true; # when using thin provisioning or caching
}
