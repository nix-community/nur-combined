{
  flake.modules.nixos.virt =
    { config, pkgs, ... }:
    {

      users.users.${config.identity.user}.extraGroups = [
        "podman"
        "video"
        "render"
      ];
      networking.firewall = {
        trustedInterfaces = [
          "podman*"
        ];
      };
      virtualisation = {
        vmVariant = {
          virtualisation = {
            memorySize = 2048;
            cores = 6;
          };
        };

        podman = {
          enable = true;
          dockerSocket.enable = true;
          dockerCompat = true;
          defaultNetwork.settings = {
            dns_enabled = true;
          };
        };

        oci-containers.backend = "podman";
      };
      systemd.tmpfiles.rules =
        let
          rootPodmanConf = pkgs.writeText "root-containers.conf" ''
            [network]
            network_config_dir = "/var/lib/containers/storage/networks"
          '';
        in
        [
          "d /var/lib/containers/storage/networks 0700 root root - -"

          "d /root/.config/containers 0700 root root - -"
          "L+ /root/.config/containers/containers.conf - - - - ${rootPodmanConf}"
        ];
    };
}
