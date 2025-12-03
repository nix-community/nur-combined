{ lib, pkgs, ... }:

{
  # hostId: not used for anything except zfs guardrail?
  #   [hex(ord(x)) for x in 'serv']
  # networking.hostId = "73657276";

  sane.persist.stores."ext" = {
    origin = "/mnt/pool/persist";
    storeDescription = "external HDD storage";
    defaultMethod = "bind";  #< TODO: change to "symlink"?
  };

  # increase /tmp space (defaults to 50% of RAM) for building large nix things.
  # even the stock `nixpkgs.linux` consumes > 16 GB of tmp
  fileSystems."/tmp".options = [ "size=32G" ];

  fileSystems."/nix" = {
    device = "/dev/disk/by-uuid/55555555-eeee-ffff-bbbb-000020250820";
    fsType = "btrfs";
    options = [
      "compress=zstd"
      "defaults"
    ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/2025-0820";
    fsType = "vfat";
  };

  fileSystems."/mnt/pool" = {
    # all btrfs devices of the same RAID volume use the same UUID.
    device = "UUID=40fc6e1d-ba41-44de-bbf3-1aa02c3441df";
    fsType = "btrfs";
    options = [
      # "compress=zstd"  #< not much point in compressing... mostly videos and music; media.
      "defaults"
      # `device=...` only needed if `btrfs scan` hasn't yet been run
      # see: <https://askubuntu.com/a/484374>
      # i don't know what guarantees NixOS/systemd make about that, so specifying all devices for now
      # "device=/dev/disk/by-partuuid/14a7d00a-be53-2b4e-96f9-7e2c964674ec"  #< removed 2024-11-24 (for capacity upgrade)
      "device=/dev/disk/by-partuuid/409a147e-2282-49eb-87a7-c968032ede88"  #< added 2024-11-24
      # "device=/dev/disk/by-partuuid/6b86cc10-c3cc-ec4d-b20d-b6688f0959a6"  #< removed 2025-06-04 (early drive failure; capacity upgrade)
      # "device=/dev/disk/by-partuuid/7fd85cac-b6f3-8248-af4e-68e703d11020"  #< removed 2024-11-13 (early drive failure)
      "device=/dev/disk/by-partuuid/92ebbbfb-022f-427d-84d5-39349d4bc02a"  #< added 2025-05-14
      "device=/dev/disk/by-partuuid/9e6c06b0-4a39-4d69-813f-1f5992f62ed7"  #< added 2025-06-05
      "device=/dev/disk/by-partuuid/d9ad5ebc-0fc4-4d89-9fd0-619ce5210f1b"  #< added 2024-11-13
      # "device=/dev/disk/by-partuuid/ef0e5c7b-fccf-f444-bac4-534424326159"  #< removed 2025-05-14 (early drive failure)
      "nofail"
      # "x-systemd.before=local-fs.target"
      "x-systemd.device-bound=false"  #< don't unmount when `device` disappears (i thought this was necessary, for drive replacement, but it might not be)
      "x-systemd.device-timeout=60s"
      "x-systemd.mount-timeout=60s"
    ];
  };

  # TODO: move this elsewhere and automate the ACLs!
  # FIRST TIME SETUP FOR MEDIA DIRECTORY:
  # - set the group sticky bit: `sudo find /var/media -type d -exec chmod g+s {} +`
  #   - this ensures new files/dirs inherit the group of their parent dir (instead of the user who creates them)
  # - ensure everything under /var/media is mounted with `-o acl`, to support acls
  # - ensure all files are rwx by group: `setfacl --recursive --modify d:g::rwx /var/media`
  #   - alternatively, `d:g:media:rwx` to grant `media` group even when file has a different owner, but that's a bit complex
  sane.persist.sys.byStore.ext = [{
    path = "/var/media";
    user = "colin";
    group = "media";
    mode = "0775";
  }];
  sane.fs."/var/media/archive".dir = {};
  sane.fs."/var/media/archive/temp".dir = {};
  # this is file.text instead of symlink.text so that it may be read over a remote mount (where consumers might not have any /nix/store/.../README.md path)
  sane.fs."/var/media/archive/temp/README.md".file.text = ''
    this directory is for media i wish to remove from my library,
    but keep for a short time in case i reverse my decision.
    treat it like a system trash can.
  '';
  sane.fs."/var/media/Books".dir = {};
  sane.fs."/var/media/Books/Audiobooks".dir = {};
  sane.fs."/var/media/Books/Books".dir = {};
  sane.fs."/var/media/Books/Visual".dir = {};
  sane.fs."/var/media/collections".dir = {};
  sane.fs."/var/media/freeleech".dir = {};
  sane.fs."/var/media/Music".dir = {};
  sane.fs."/var/media/Pictures".dir = {};
  sane.fs."/var/media/Videos".dir = {};
  sane.fs."/var/media/Videos/Film".dir = {};
  sane.fs."/var/media/Videos/Shows".dir = {};
  sane.fs."/var/media/Videos/Talks".dir = {};

  systemd.services.dedupe-media = {
    description = "transparently de-duplicate /var/media entries by using block-level hardlinks";
    script = ''
      ${lib.getExe' pkgs.util-linux "hardlink"} /var/media --reflink=always --ignore-time --verbose
    '';
  };
  systemd.timers.dedupe-media = {
    wantedBy = [ "multi-user.target" ];
    timerConfig = {
      OnStartupSec = "23min";
      OnUnitActiveSec = "720min";
    };
  };
}

