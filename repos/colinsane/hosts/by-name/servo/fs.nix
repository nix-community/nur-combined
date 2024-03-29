# zfs docs:
# - <https://nixos.wiki/wiki/ZFS>
# - <repo:nixos/nixpkgs:nixos/modules/tasks/filesystems/zfs.nix>
#
# zfs check health: `zpool status`
#
# zfs pool creation (requires `boot.supportedFilesystems = [ "zfs" ];`
# - 1. identify disk IDs: `ls -l /dev/disk/by-id`
# - 2. pool these disks: `zpool create -f -m legacy pool raidz ata-ST4000VN008-2DR166_WDH0VB45 ata-ST4000VN008-2DR166_WDH17616 ata-ST4000VN008-2DR166_WDH0VC8Q ata-ST4000VN008-2DR166_WDH17680`
#   - legacy documented: <https://superuser.com/questions/790036/what-is-a-zfs-legacy-mount-point>
#
# import pools: `zpool import pool`
# show zfs datasets: `zfs list` (will be empty if haven't imported)
# show zfs properties (e.g. compression): `zfs get all pool`
# set zfs properties: `zfs set compression=on pool`
{ ... }:

{
  # hostId: not used for anything except zfs guardrail?
  #   [hex(ord(x)) for x in 'serv']
  networking.hostId = "73657276";
  boot.supportedFilesystems = [ "zfs" ];
  # boot.zfs.enabled = true;
  boot.zfs.forceImportRoot = false;
  # scrub all zfs pools weekly:
  services.zfs.autoScrub.enable = true;
  boot.extraModprobeConfig = ''
    # ZFS likes to use half the ram for its own cache and let the kernel push everything else to swap.
    # so, reduce its cache size
    # see: <https://askubuntu.com/a/1290387>
    # see: <https://serverfault.com/a/1119083>
    # see: <https://openzfs.github.io/openzfs-docs/Performance%20and%20Tuning/Module%20Parameters.html#zfs-arc-max>
    # for all tunables, see: `man 4 zfs`
    # to update these parameters without rebooting:
    # - `echo '4294967296' | sane-sudo-redirect /sys/module/zfs/parameters/zfs_arc_max`
    options zfs zfs_arc_max=4294967296
  '';
  # to be able to mount the pool like this, make sure to tell zfs to NOT manage it itself.
  # otherwise local-fs.target will FAIL and you will be dropped into a rescue shell.
  # - `zfs set mountpoint=legacy pool`
  # if done correctly, the pool can be mounted before this `fileSystems` entry is created:
  # - `sudo mount -t zfs pool /mnt/persist/pool`
  fileSystems."/mnt/pool" = {
    device = "pool";
    fsType = "zfs";
  };
  # services.zfs.zed = ... # TODO: zfs can send me emails when disks fail
  sane.programs.sysadminUtils.suggestedPrograms = [ "zfs" ];

  sane.persist.stores."ext" = {
    origin = "/mnt/pool/persist";
    storeDescription = "external HDD storage";
    defaultMethod = "bind";  #< TODO: change to "symlink"?
  };

  # increase /tmp space (defaults to 50% of RAM) for building large nix things.
  # even the stock `nixpkgs.linux` consumes > 16 GB of tmp
  fileSystems."/tmp".options = [ "size=32G" ];

  fileSystems."/nix" = {
    device = "/dev/disk/by-uuid/cc81cca0-3cc7-4d82-a00c-6243af3e7776";
    fsType = "btrfs";
    options = [
      "compress=zstd"
      "defaults"
    ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/6EE3-4171";
    fsType = "vfat";
  };

  # slow, external storage (for archiving, etc)
  fileSystems."/mnt/usb-hdd" = {
    device = "/dev/disk/by-uuid/aa272cff-0fcc-498e-a4cb-0d95fb60631b";
    fsType = "btrfs";
    options = [
      "compress=zstd"
      "defaults"
    ];
  };
  sane.fs."/mnt/usb-hdd".mount = {};

  sane.persist.sys.byStore.plaintext = [{
    path = "/var/media";
    method = "bind";  #< this HAS to be `bind` if we're going to persist the whole thing but create subdirs, as below.
    user = "colin";
    group = "media";
    mode = "0755";
  }];
  sane.fs."/var/media/archive".dir = {};
  # this is file.text instead of symlink.text so that it may be read over a remote mount (where consumers might not have any /nix/store/.../README.md path)
  sane.fs."/var/media/archive/README.md".file.text = ''
    this directory is for media i wish to remove from my library,
    but keep for a short time in case i reverse my decision.
    treat it like a system trash can.
  '';
  sane.fs."/var/media/Books".dir = {};
  sane.fs."/var/media/Books/Audiobooks".dir = {};
  sane.fs."/var/media/Books/Books".dir = {};
  sane.fs."/var/media/Books/Visual".dir = {};
  sane.fs."/var/media/collections".dir = {};
  sane.fs."/var/media/datasets".dir = {};
  sane.fs."/var/media/freeleech".dir = {};
  sane.fs."/var/media/Music".dir = {};
  sane.fs."/var/media/Pictures".dir = {};
  sane.fs."/var/media/Videos".dir = {};
  sane.fs."/var/media/Videos/Film".dir = {};
  sane.fs."/var/media/Videos/Shows".dir = {};
  sane.fs."/var/media/Videos/Talks".dir = {};

  # this is file.text instead of symlink.text so that it may be read over a remote mount (where consumers might not have any /nix/store/.../README.md path)
  sane.fs."/var/lib/uninsane/datasets/README.md".file.text = ''
    this directory may seem redundant with ../media/datasets. it isn't.
    this directory exists on SSD, allowing for speedy access to specific datasets when necessary.
    the contents should be a subset of what's in ../media/datasets.
  '';
  # make sure large media is stored to the HDD
  sane.persist.sys.byStore.ext = [
    {
      user = "colin";
      group = "users";
      mode = "0777";
      path = "/var/media/Videos";
    }
    {
      user = "colin";
      group = "users";
      mode = "0777";
      path = "/var/media/freeleech";
    }
    {
      user = "colin";
      group = "users";
      mode = "0775";
      path = "/var/lib/uninsane/datasets";
    }
  ];

  # btrfs doesn't easily support swapfiles
  # swapDevices = [
  #   { device = "/nix/persist/swapfile"; size = 4096; }
  # ];

  # this can be a partition. create with:
  #   fdisk <dev>
  #     n
  #     <default partno>
  #     <start>
  #     <end>
  #     t
  #     <partno>
  #     19  # set part type to Linux swap
  #     w   # write changes
  #   mkswap -L swap <part>
  # swapDevices = [
  #   {
  #     label = "swap";
  #     # TODO: randomEncryption.enable = true;
  #   }
  # ];
}

