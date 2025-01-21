{ ... }:
{
  # snapper: btrfs auto-snapshots:
  # - <https://wiki.archlinux.org/title/Snapper>
  # - `man snapper-configs`
  #
  # to list snapshots: `snapper list`
  # to take a snapshot: `snapper create`  or `systemctl start snapper-timeline.service`
  #
  # FIRST TIME SETUP:
  # - `sudo btrfs subvolume create /nix/persist`
  #   - if migrating from a non-subvol `/nix/persist`, then:
  #     - `sudo btrfs subvolume create /nix/persist.new`
  #     - `sudo cp --archive --one-file-system --reflink=always /nix/persist/. /nix/persist.new`
  #     - `sudo bash -c 'mv /nix/persist /nix/persist.old && mv /nix/persist.new /nix/persist`
  # - `sudo btrfs subvolume create /nix/persist/.snapshots`
  # - reboot (else all snapper calls will fail due to dbus errors)
  services.snapper.configs.root = {
    SUBVOLUME = "/nix/persist";
    ALLOW_USERS = [ "colin" ];
    TIMELINE_CLEANUP = true;  # remove old snapshots every 24h
    TIMELINE_CREATE = true;  # take a snapshot every hour
    TIMELINE_LIMIT_HOURLY = 12;
    TIMELINE_LIMIT_DAILY = 7;  # keep snapshots for 1d ago, 2d ago, ... 7day ago
    TIMELINE_LIMIT_WEEKLY = 4;  # keep snapshots for 7d ago, 14d ago, 21d ago, 28d ago
    TIMELINE_LIMIT_MONTHLY = 0;
    TIMELINE_LIMIT_YEARLY = 0;
  };
}
