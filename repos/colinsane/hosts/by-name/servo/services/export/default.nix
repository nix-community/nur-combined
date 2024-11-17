{ config, ... }:
{
  imports = [
    ./nfs.nix
    ./sftpgo
  ];

  users.groups.export = {};

  fileSystems."/var/export/media" = {
    # everything in here could be considered publicly readable (based on the viewer's legal jurisdiction)
    device = "/var/media";
    options = [ "rbind" "nofail" ];
  };
  # fileSystems."/var/export/playground" = {
  #   device = config.fileSystems."/mnt/persist/ext".device;
  #   fsType = "btrfs";
  #   options = [
  #     "subvol=export-playground"
  #     "compress=zstd"
  #     "defaults"
  #   ];
  # };
  # N.B.: the backing directory should be manually created here **as a btrfs subvolume** and with a quota.
  # - `sudo btrfs subvolume create /mnt/persist/ext/persist/var/export/playground`
  # - `sudo btrfs quota enable /mnt/persist/ext/persist/var/export/playground`
  # - `sudo btrfs quota rescan -sw /mnt/persist/ext/persist/var/export/playground`
  # to adjust the limits (which apply at the block layer, i.e. post-compression):
  # - `sudo btrfs qgroup limit 20G /mnt/persist/ext/persist/var/export/playground`
  # to query the quota/status:
  # - `sudo btrfs qgroup show -re /var/export/playground`
  sane.persist.sys.byStore.ext = [
    { user = "root"; group = "export"; mode = "0775"; path = "/var/export/playground"; method = "bind"; }
  ];

  sane.fs."/var/export/README.md" = {
    file.text = ''
      - media/         read-only:  Videos, Music, Books, etc
      - playground/    read-write*: use it to share files with other users of this server, inaccessible from the www
                                    *if you can't write to it, make sure you're connected to the WiFi and not mobile.
    '';
  };

  sane.fs."/var/export/playground/README.md" = {
    file.text = ''
      this directory is intentionally read+write by anyone with access.
      - share files
      - write poetry
      - be a friendly troll
    '';
  };

  sane.fs."/var/export/.public_for_test/test" = {
    file.text = ''
      automated tests read this file to probe connectivity
    '';
  };
}
