{ config, lib, ... }:

let
  inherit (config) host;
  inherit (config.services) apt-cacher-ng;
  inherit (lib) mkIf mkMerge;
  inherit (lib.generators) toYAML;

  identity = import ../library/identity.lib.nix { inherit lib; };
  toCloudConfig = data: "#cloud-config\n${toYAML { } data}";
in
mkMerge [
  {
    # Podman
    virtualisation.containers.registries.search = [ "docker.io" ];
    virtualisation.podman = { enable = true; autoPrune.enable = true; };
    systemd.timers.podman-prune.unitConfig.ConditionACPower = true;
    users.extraGroups.podman.members = [ identity.username ];
  }
  (mkIf host.features.vm {
    # Incus
    virtualisation.incus = {
      enable = true;
      socketActivation = true;
      preseed = let gateway = "10.26.0.1"; in {
        storage_pools = [{
          name = "default";
          driver = "btrfs";
          config.source = "/var/lib/incus/storage-pools/default";
        }];
        networks = [{
          name = "incusbr0";
          config = {
            "ipv4.address" = "${gateway}/24";
            "ipv4.nat" = "true";
            "ipv6.address" = "none";
          };
        }];
        profiles = [
          {
            name = "default";
            devices = {
              root = { type = "disk"; path = "/"; pool = "default"; };
              eth0 = { type = "nic"; name = "eth0"; network = "incusbr0"; };
            };
          }
          {
            name = "apt_cache";
            config."cloud-init.user-data" = toCloudConfig {
              apt = {
                http_proxy = "http://${gateway}:${toString apt-cacher-ng.port}";
                https_proxy = "DIRECT";
              };
            };
          }
        ];
      };
    };
    users.extraGroups.incus-admin.members = [ identity.username ];
    networking.firewall.interfaces.incusbr0 = {
      allowedTCPPorts = [ apt-cacher-ng.port ];
      allowedUDPPorts = [ 53 67 ];
    };

    # VirtualBox
    virtualisation.virtualbox.host.enable = true;
    users.extraGroups.vboxusers.members = [ identity.username ];
    boot.kernelParams = [ "kvm.enable_virt_at_load=0" ]; # Workaround to NixOS/nixpkgs#363887
  })
]
