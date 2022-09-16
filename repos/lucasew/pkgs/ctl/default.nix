{ lib, pkgs }:
lib.climod {
  imports = [
    ./deploy.nix
  ];
  name = "ctl";
  description = "lucasew's control CLI";
}
