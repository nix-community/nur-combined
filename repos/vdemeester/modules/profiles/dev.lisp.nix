{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.profiles.dev.lisp;
in
{
  options = {
    profiles.dev.lisp = {
      enable = mkEnableOption "Enable lisp development profile";
    };
  };
  config = mkIf cfg.enable {
    home-packages = with pkgs; [
      sbcl
      asdf
    ];
  };
}
