{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.profiles.docker;
in
{
  options = {
    profiles.docker = {
      enable = mkOption {
        default = false;
        description = "Enable docker profile";
        type = types.bool;
      };
      package = mkOption {
        default = pkgs.docker-edge;
        description = "docker package to be used";
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
    profiles.containerd.enable = true;
    virtualisation = {
      docker = {
        enable = true;
        package = cfg.package;
        liveRestore = false;
        storageDriver = "overlay2";
        extraOptions = "--experimental --add-runtime docker-runc=${cfg.runcPackage}/bin/runc --default-runtime=docker-runc --containerd=/run/containerd/containerd.sock";
      };
    };
    environment.etc."docker/daemon.json".text = ''
      {"features":{"buildkit": true}, "insecure-registries": ["172.30.0.0/16", "192.168.12.0/16", "massimo.home:5000", "r.svc.home:5000", "r.svc.home" ]}
    '';
    networking.firewall.trustedInterfaces = [ "docker0" ];
  };
}
