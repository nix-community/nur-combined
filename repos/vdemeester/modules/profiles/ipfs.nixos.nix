{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.profiles.ipfs;
in
{
  options = {
    profiles.ipfs = {
      enable = mkOption {
        default = false;
        description = "Enable ipfs profile";
        type = types.bool;
      };
      autoMount = mkOption {
        default = true;
        description = "Automount /ipfs and /ipns";
        type = types.bool;
      };
      localDiscovery = mkOption {
        default = true;
        description = "Enable local discovery, switch profile to server if disable";
        type = types.bool;
      };
      extraConfig = mkOption {
        default = {
          Datastore.StorageMax = "40GB";
        };
        description = "Extra ipfs daemon configuration";
        type = types.attrs;
      };
    };
  };
  config = mkIf cfg.enable {
    services.ipfs = {
      enable = true;
      enableGC = true;
      localDiscovery = cfg.localDiscovery;
      autoMount = cfg.autoMount;
      extraConfig = cfg.extraConfig;
    };
  };
}
