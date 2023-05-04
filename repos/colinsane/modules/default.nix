{ lib, ... }:

{
  imports = [
    ./feeds.nix
    ./fs
    ./ids.nix
    ./programs.nix
    ./image.nix
    ./persist
    ./services
    ./sops.nix
    ./ssh.nix
    ./users.nix
  ];

  _module.args =  {
    sane-lib = import ./lib { inherit lib; };
    sane-data = import ./data { inherit lib; };
  };
}
