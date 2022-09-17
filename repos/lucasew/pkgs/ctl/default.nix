{ lib, pkgs }:
lib.climod {
  imports = [
    ./deploy
    ./options
  ];
  name = "ctl";
  description = "lucasew's control CLI";
}
