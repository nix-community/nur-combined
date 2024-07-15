{ lib, ... }:

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
    ./sops.nix
    ./ssh.nix
    ./users
    ./vpn.nix
    ./warnings.nix
    ./wowlan.nix
  ];

  _module.args =  rec {
    sane-lib = import ./lib { inherit lib; };
    sane-data = import ./data { inherit lib sane-lib; };
  };
}
