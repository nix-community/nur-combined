{ config, ... }:
let
  publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKAUdxAZHd02htr4UkdmKgZDZqSA15G49rzkTypDNA7P";
in
{
  users.mutableUsers = false;
  sops.secrets.user_nixos_passwd = {
    neededForUsers = true;
  };
  users.users.nixos = {
    isNormalUser = true;
    hashedPasswordFile = config.sops.secrets.user_nixos_passwd.path;
    extraGroups = [
      "adbusers"
      "aria2"
      "audio"
      "dialout"
      "docker"
      "libvirtd"
      "podman"
      "render"
      "vboxusers"
      "video"
      "wheel"
      config.services.syncthing.group
      config.users.groups.keys.name
    ];
  };

  users.users.root.openssh.authorizedKeys.keys = [ publicKey ];
  programs.ssh.knownHosts."local.lan".publicKey = publicKey;
}
