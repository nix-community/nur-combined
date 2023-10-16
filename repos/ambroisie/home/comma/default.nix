{ config, lib, pkgs, ... }:
let
  cfg = config.my.home.comma;
in
{
  options.my.home.comma = with lib; {
    enable = my.mkDisableOption "comma configuration";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      ambroisie.comma
    ];
  };
}
