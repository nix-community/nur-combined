{config, pkgs, lib, ...}:
let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.programs.adskipped-spotify;
in {
   options = {
     programs.adskipped-spotify = {
       enable = mkEnableOption "enable spotify with adskipper";
     };
   };
   config = mkIf cfg.enable {
    systemd.user.services.spotify-adblock = import ./service.nix {inherit pkgs;};
    home.packages = [
      pkgs.spotify
    ];
  };
}
