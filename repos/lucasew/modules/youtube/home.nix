{config, pkgs, lib, ...}:
with lib;
let
  customYoutube = pkgs.callPackage ./package.nix {};
in
{
  config = {
    systemd.user.services.ytmd-adblock = import ./adskip_service.nix {inherit pkgs;};
    home.packages = [
      customYoutube
    ];
  };
}
