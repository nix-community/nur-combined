{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.profiles.dev.python;
in
{
  options = {
    profiles.dev.python = {
      enable = mkEnableOption "Enable python development profile";
    };
  };
  config = mkIf cfg.enable {
    profiles.dev.enable = true;
    home.packages = with pkgs; [
      python3
      python36Packages.virtualenv
      python36Packages.pip-tools
      python36Packages.tox
      pipenv
    ];
  };
}
