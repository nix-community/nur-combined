{ pkgs, ... }:
let
  publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKAUdxAZHd02htr4UkdmKgZDZqSA15G49rzkTypDNA7P";
in
{
  users.users.nixos = {
    isNormalUser = true;
    extraGroups = [
      "adbusers"
      "aria2"
      "docker"
      "vboxusers"
      "wheel"
    ];
  };

  users.users.root.openssh.authorizedKeys.keys = [ publicKey ];
  programs.ssh.knownHosts."local.local".publicKey = publicKey;
}
