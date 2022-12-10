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
    system.fsPackages = [ pkgs.nfs-utils ];
    systemd.mounts = [{
      type = "nfs";
      what = "robocat:/data";
      where = "/data";
    }];
    systemd.automounts = [{
      wantedBy = [ "multi-user.target" ];
      automountConfig = {
        TimeoutIdleSec = "600";
      };
      where = "/data";
    }];
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
      systems = [ "x86_64-linux" "i686-linux" ];
      supportedFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];
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
      logLevel = "debug";
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
