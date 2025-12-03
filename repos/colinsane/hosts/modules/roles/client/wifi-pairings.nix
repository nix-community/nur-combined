{ config, lib, pkgs, ... }:

let
  install-nm = pkgs.static-nix-shell.mkPython3 {
    pname = "install-nm";
    srcRoot = ./.;
  };
in
{
  config = lib.mkIf config.sane.roles.client {
    sops.secrets."net/all.json".owner = "networkmanager";

    systemd.services.iwd-provision-secrets = {
      before = [ "iwd.service" ];
      wantedBy = [ "iwd.service" ];
      serviceConfig.ExecStart = "${lib.getExe install-nm} /run/secrets/net/all.json /var/lib/iwd --flavor iwd";
      serviceConfig.Type = "oneshot";
    };

    sane.fs."/var/lib/NetworkManager/system-connections".dir.acl = {
      user = "networkmanager";
      group = "networkmanager";
      mode = "0700";
    };
    systemd.services.NetworkManager-provision-secrets = {
      after = [ "systemd-tmpfiles-setup.service" ];  #< for sane.fs; ensure system-connections exists as a directory first.
      before = [ "NetworkManager.service" ];
      wantedBy = [ "NetworkManager.service" ];
      serviceConfig.ExecStart = "${lib.getExe install-nm} /run/secrets/net/all.json /var/lib/NetworkManager/system-connections --flavor nm";
      serviceConfig.Type = "oneshot";
      serviceConfig.UMask = "0077";  #< NetworkManager considers any files not 0600 "insecure" and refuses to load them (sure bro, sure)
      serviceConfig.User = "networkmanager";
      serviceConfig.Group = "networkmanager";
    };
  };
}
