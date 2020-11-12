{config, pkgs, lib, ...}:
with lib;
 {
    config = {
      systemd.user.services.spotify-adblock = import ./service.nix {inherit pkgs;};
      home.packages = [
        pkgs.spotify
      ];
    };
}
