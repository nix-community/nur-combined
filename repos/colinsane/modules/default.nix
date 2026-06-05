{ ... }:

{
  imports = [
    ./dns.nix
    ./feeds.nix
    ./fs
    ./ids.nix
    ./programs
    ./image.nix
    ./netns.nix
    ./persist
    ./ports.nix
    ./root-on-tmpfs.nix
    ./services
    ./ssh.nix
    ./users
    ./vpn.nix
    ./warnings.nix
    ./wowlan.nix
  ];
}
