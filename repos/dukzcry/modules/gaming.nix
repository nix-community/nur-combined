{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.programs.gaming;
in {
  options.programs.gaming = {
    enable = mkEnableOption "gaming support";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      # https://github.com/lutris/lutris/issues/5121
      wine wine64
      # https://github.com/NixOS/nixpkgs/issues/292620
      gamescope
      lutris steamPackages.steam-fhsenv-without-steam.run
    ];
  };
}
