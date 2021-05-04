{ config, lib, ... }:
let
  cfg = config.my.home.x;
in
{
  imports = [
    ./keyboard.nix
  ];

  options.my.home.x = with lib; {
    enable = mkEnableOption "X server configuration";
  };

  config = lib.mkIf cfg.enable {
    xsession.enable = true;
  };
}
