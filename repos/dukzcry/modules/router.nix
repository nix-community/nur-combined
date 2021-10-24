{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.services.router;
in {
  options.services.router = {
    enable = mkEnableOption ''
      Router support
    '';
  };

  config = mkIf cfg.enable {
    fileSystems."/data" = {
      device = "robocat:/data";
      fsType = "nfs";
      options = [ "x-systemd.automount" "noauto" ];
    };
    environment = {
      systemPackages = with pkgs; [
        picocom
        jellyfin-media-player
        transmission-remote-gtk
      ];
    };
    nix.buildMachines = [{
      hostName = "robocat";
      system = "x86_64-linux";
      supportedFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];
      maxJobs = 8;
    }];
    nix.extraOptions = ''
      builders-use-substitutes = true
    '';
    nix.distributedBuilds = true;

    virtualisation.libvirtd.enable = lib.mkForce false;
    services.tor.enable = lib.mkForce false;
  };
}
