{ config, pkgs, lib, ... }:

{
  config = lib.mkIf config.services.nomad.enable {
    services.nomad = {
      extraSettingsPlugins = [
        pkgs.nomad-driver-podman
      ];
      dropPrivileges = false;
      settings = {
        data_dir = "/var/lib/private/nomad";
        datacenter = lib.mkDefault "br_home_local";
        bind_addr = "{{ GetInterfaceIP \"tailscale0\" }}"; # Dynamically binds to Tailscale IP
        "advertise" = {
          "http" = "{{ GetInterfaceIP \"tailscale0\" }}";
          "rpc" = "{{ GetInterfaceIP \"tailscale0\" }}";
          "serf" = "{{ GetInterfaceIP \"tailscale0\" }}";
        };
        client = {
          enabled = true;
          network_interface = "tailscale0";
          alloc_mounts_dir = "/var/lib/private/nomad/alloc_mounts";
          server_join = {
            retry_join = [
              "ravenrock:4647"
            ];
          };
        };
        plugin = [
          {
            nomad-driver-podman = {
              config = {
              };
            };
          }
          {
            docker = {
              config = {
                image_pull_timeout = "30m";
              };
            };
          }
        ];
      };
    };

    # Nomad resolves/binds against tailscale0; ensure it starts after
    # Tailscale daemon, autoconnect, and device availability at boot.
    systemd.services.nomad = {
      wantedBy = [ "multi-user.target" ];
      wants = [
        "network-online.target"
        "tailscaled.service"
        "tailscale-autoconnect.service"
      ];
      after = [
        "network-online.target"
        "tailscaled.service"
        "tailscale-autoconnect.service"
        "sys-subsystem-net-devices-tailscale0.device"
      ];
      bindsTo = [ "sys-subsystem-net-devices-tailscale0.device" ];
      requires = [ "tailscaled.service" ];
    };
  };
}
