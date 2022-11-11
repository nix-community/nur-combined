imports: { config, lib, pkgs, ... }:

with lib;
let
  cfg = config.services.server;
  ip4 = pkgs.nur.repos.dukzcry.lib.ip4;
in {
  inherit imports;

  options.services.server = {
    enable = mkEnableOption ''
      Support for my home server
    '';
  };

  config = mkIf cfg.enable {
    fileSystems."/mnt/data" = {
      device = "robocat:/data";
      fsType = "nfs";
      options = [ "x-systemd.automount" "noauto" ];
    };
    environment = {
      systemPackages = with pkgs; [
        jellyfin-media-player
        transmission-remote-gtk
        moonlight-qt
        pkgs.nur.repos.dukzcry.cockpit-client
      ];
    };
    nix.buildMachines = [{
      hostName = "robocat";
      system = "x86_64-linux";
      supportedFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" "i686-linux" ];
      maxJobs = 8;
    }];
    nix.extraOptions = ''
      builders-use-substitutes = true
    '';
    nix.distributedBuilds = true;

    virtualisation.libvirtd.enable = lib.mkForce false;
    virtualisation.spiceUSBRedirection.enable = true;
    services.tor.enable = lib.mkForce false;

    networking.edgevpn = {
      enable = true;
      dhcp = false;
      logLevel = "debug";
      address = ip4.fromString "10.0.1.2/24";
      router = "10.0.1.1";
      postStart = ''
        ip route add dev ${config.networking.edgevpn.interface} 10.0.0.0/24
        echo -e "nameserver 10.0.0.1\nsearch local" | resolvconf -a ${config.networking.edgevpn.interface}
      '';
      postStop = ''
        resolvconf -d ${config.networking.edgevpn.interface}
      '';
    };
  };
}
