{ config, lib,  sane-lib, ... }:

let
  keysForHost = hostName: let
    hostCfg = config.sane.hosts.by-name."${hostName}";
  in {
    "root@${hostName}" = hostCfg.ssh.host_pubkey;
    "colin@${hostName}" = lib.mkIf (hostCfg.ssh.user_pubkey != null && hostCfg.ssh.authorized) hostCfg.ssh.user_pubkey;
  };
  hostKeys = builtins.map keysForHost (builtins.attrNames config.sane.hosts.by-name);
in
{
  sane.ssh.pubkeys = lib.mkMerge (hostKeys ++ [
    {
      "root@uninsane.org" = config.sane.hosts.by-name.servo.ssh.host_pubkey;
      "root@git.uninsane.org" = config.sane.hosts.by-name.servo.ssh.host_pubkey;

      # documented here: <https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/githubs-ssh-key-fingerprints>
      # Github actually uses multiple keys -- one per format
      "root@github.com" = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl";
    }
  ]);

  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "no";
    settings.PasswordAuthentication = false;
  };
  sane.ports.ports."22" = {
    protocol = [ "tcp" ];
    visibleTo.lan = true;
    description = lib.mkDefault "colin-ssh";
  };
}
