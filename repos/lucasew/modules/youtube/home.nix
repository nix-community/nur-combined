{config, pkgs, lib, ...}:
with lib;
let
  customYoutube = pkgs.callPackage ./package.nix {};
in
{
  options = {
    programs.adskipped-youtube-music = {
      enable = mkEnableOption "enable youtube music with adskipper";
    };
  };
  config = mkIf config.programs.adskipped-youtube-music.enable {
    systemd.user.services.ytmd-adblock = import ./service.nix {inherit pkgs;};
    home.packages = [
      customYoutube
    ];
  };
}
