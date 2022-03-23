imports: { config, lib, pkgs, ... }:

with lib;
let
  cfg = config.services.server;
in {
  inherit imports;

  options.services.server = {
    enable = mkEnableOption ''
      Support for my home server
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
        nextcloud-client
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
    virtualisation.spiceUSBRedirection.enable = true;
    #services.tor.enable = lib.mkForce false;

    networking.edgevpn = {
      enable = true;
      address = "10.0.2.1/24";
      router = "10.0.2.1";
      postStart = ''
        ip route add dev ${config.networking.edgevpn.interface} 10.0.0.0/24
        ip route add dev ${config.networking.edgevpn.interface} 10.0.1.0/24
        echo -e "nameserver 10.0.0.2\nsearch local" | resolvconf -a ${config.networking.edgevpn.interface}
      '';
      postStop = ''
        resolvconf -d ${config.networking.edgevpn.interface}
      '';
    };
  };
}
