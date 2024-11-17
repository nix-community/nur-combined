{ config, lib, ... }:

let
  hostKeys = lib.mapAttrsToList
    (hostName: hostCfg:
      # generate `root@servo`, `colin@servo`, `root@servo-hn`, `colin@servo-hn`, ... as a single attrset:
      lib.foldl' (acc: alias: acc // {
        "root@${alias}" = hostCfg.ssh.host_pubkey;
        "colin@${alias}" = lib.mkIf (hostCfg.ssh.user_pubkey != null && hostCfg.ssh.authorized) hostCfg.ssh.user_pubkey;
      })
      {}
      hostCfg.names
    )
    config.sane.hosts.by-name;
in
{
  sane.ssh.pubkeys = lib.mkMerge (hostKeys ++ [
    {
      "root@uninsane.org" = config.sane.hosts.by-name.servo.ssh.host_pubkey;
      "root@git.uninsane.org" = config.sane.hosts.by-name.servo.ssh.host_pubkey;

      # documented here: <https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/githubs-ssh-key-fingerprints>
      # Github actually uses multiple keys -- one per format
      "root@github.com" = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl";

      # documented: <https://docs.gitlab.com/ee/user/gitlab_com/index.html#ssh-known_hosts-entries>
      "root@gitlab.com" = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAfuCHKVTjquxvt6CM6tdG4SLp1Btn/nOeHHE5UOzRdf";

      # documented: <https://www.rsync.net/resources/fingerprints.txt>
      # extract keys with `ssh-keyscan sd1.rsync.net`
      # validate fingerprint with `ssh-keyscan sd1.rsync.net | ssh-keygen -l -f -`
      "root@*.rsync.net" = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINdUkGe6kKn5ssz4WRZKjcws0InbQqZayenzk9obmP1z";
    }
  ]);

  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "no";
    settings.PasswordAuthentication = false;
    # settings.UsePAM = lib.mkDefault false;  #< notably, disables systemd session tracking; incidentally disables pam_mount, etc.
  };
  sane.ports.ports."22" = {
    protocol = [ "tcp" ];
    visibleTo.lan = true;
    description = lib.mkDefault "colin-ssh";
  };

  # sane.services.dropbear = {
  #   enable = true;
  #   port = 1022;
  # };
  # sane.ports.ports."1022" = {
  #   protocol = [ "tcp" ];
  #   visibleTo.lan = true;
  #   description = lib.mkDefault "colin-dropbear-ssh";
  # };
}
