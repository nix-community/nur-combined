{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit
    (lib)
    mkEnableOption
    ;
in {
  imports = [
    ./cursor.nix
    ./i3.nix
    ./i3bar.nix
  ];

  options.my.home.x = {
    enable = mkEnableOption "X server configuration";
  };
}
