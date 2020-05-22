{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.profiles.containerd;
in
{
  options = {
    profiles.containerd = {
      enable = mkOption {
        default = false;
        description = "Enable containerd profile";
        type = types.bool;
      };
      package = mkOption {
        default = pkgs.my.containerd;
        description = "containerd package to be used";
        type = types.package;
      };
      runcPackage = mkOption {
        default = pkgs.runc;
        description = "runc package to be used";
        type = types.package;
      };
      cniPackage = mkOption {
        default = pkgs.cni;
        description = "cni package to be used";
        type = types.package;
      };
      cniPluginsPackage = mkOption {
        default = pkgs.cni-plugins;
        description = "cni-plugins package to be used";
        type = types.package;
      };
    };
  };
  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      cfg.cniPackage
      cfg.cniPluginsPackage
      cfg.package
      cfg.runcPackage
    ];
    virtualisation = {
      containerd = {
        enable = true;
        package = cfg.package;
        packages = [ cfg.runcPackage ];
      };
    };
  };
}
