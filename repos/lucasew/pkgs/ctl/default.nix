{ lib, pkgs }:
lib.climod {
  imports = [
    ./deploy
    ./options
    ./send2kindle.nix
    ./ansible.nix
  ];
  name = "ctl";
  description = "lucasew's control CLI";
}
