{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.profiles.buildkit;
in
{
  options = {
    profiles.buildkit = {
      enable = mkOption {
        default = false;
        description = "Enable buildkit profile";
        type = types.bool;
      };
      package = mkOption {
        default = pkgs.my.buildkit;
        description = "buildkit package to be used";
        type = types.package;
      };
      runcPackage = mkOption {
        default = pkgs.runc;
        description = "runc package to be used";
        type = types.package;
      };
    };
  };
  config = mkIf cfg.enable {
    profiles.containerd = {
      enable = true;
      runcPackage = cfg.runcPackage;
    };
    environment.systemPackages = with pkgs; [
      cfg.package
    ];
    virtualisation = {
      buildkitd = {
        enable = true;
        package = cfg.package;
        packages = [ cfg.runcPackage pkgs.git ];
        extraOptions = "--oci-worker=false --containerd-worker=true";
      };
    };
  };
}
