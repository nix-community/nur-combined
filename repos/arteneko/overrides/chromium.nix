{ pkgs, ... }:
pkgs.chromium.override {
  commandLineArgs = "--force-dark-mode=enabled";
}
