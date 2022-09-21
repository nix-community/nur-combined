{ lib, pkgs }:
lib.climod {
  imports = [
    ./deploy
    ./options
    ./send2kindle.nix
  ];
  name = "ctl";
  description = "lucasew's control CLI";
}
