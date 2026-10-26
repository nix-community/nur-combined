{
  flake.modules.nixos.magpie =
    { config, lib, ... }:
    {
      vaultix.secrets.magpie = {
        owner = "magpie";
        mode = "400";
      };

      users = {
        groups.magpie = { };
        users.magpie = {
          isSystemUser = true;
          group = "magpie";
          home = "/var/lib/magpie";
          linger = true;
          createHome = true;
          uid = 950;
          autoSubUidGidRange = true;
        };
      };

      systemd.services.podman-magpie = {
        after = [
          "network-online.target"
          # "vaultix-activate.service"
        ];
        # Start after the secret files exist, but do not tie the container's
        # lifetime to that unit. Every switch restarts vaultix-activate, and a
        # Requires edge turned that into a stop of this container mid-flight; the
        # podman stop then failed and left the unit failed instead of restarting.
        wants = [
          "network-online.target"
          # "vaultix-activate.service"
        ];
        serviceConfig.Restart = lib.mkForce "always";
      };

      virtualisation.oci-containers = {
        backend = "podman";
        containers.magpie = {
          image = "ghcr.io/yetone/magpie:latest";
          cmd = [
            "web"
            "--addr"
            "[::]:3430"
            "--no-open"
          ];
          ports = [
            "[::]:3425:3425"
            "[::]:3430:3430"
          ];
          volumes = [ "magpie-config:/config" ];
          environmentFiles = [ config.vaultix.secrets.magpie.path ];
          podman.user = "magpie";
        };
      };
    };
}
