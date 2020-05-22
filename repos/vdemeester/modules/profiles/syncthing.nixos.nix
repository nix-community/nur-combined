{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.profiles.syncthing;
in
{
  options = {
    profiles.syncthing = {
      enable = mkOption {
        default = false;
        description = "Enable syncthing profile";
        type = types.bool;
      };
    };
  };
  config = mkIf cfg.enable {
    services.syncthing = {
      enable = true;
      user = "vincent";
      dataDir = "/home/vincent/.syncthing";
      configDir = "/home/vincent/.syncthing";
      openDefaultPorts = true;
    };
  };
}
