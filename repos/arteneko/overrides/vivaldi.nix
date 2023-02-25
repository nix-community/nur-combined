{ pkgs, ... }:
pkgs.vivaldi.override {
  commandLineArgs = "--force-dark-mode=enabled";
}
