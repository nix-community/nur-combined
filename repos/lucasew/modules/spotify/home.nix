{config, pkgs, lib, ...}:
with lib;
 {
   options = {
     programs.adskipped-spotify = {
       enable = mkEnableOption "enable spotify with adskipper";
     };
   };
   config = mkIf config.programs.adskipped-spotify.enable {
    systemd.user.services.spotify-adblock = import ./service.nix {inherit pkgs;};
    home.packages = [
      pkgs.spotify
    ];
  };
}
