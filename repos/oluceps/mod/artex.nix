{
  flake.modules.nixos.artex =
    { config, ... }:
    {
      # ARTEX (AI autonomous pentest system) as an OCI container.
      #
      # The image is built locally from the ARTEX source tree with podman
      # (upstream Dockerfile: Playwright + recon toolset included):
      #
      #   cd ~/Src/ARTEX
      #   podman build -t artex:local \
      #     --from docker.io/library/python:3.12-slim-bookworm .
      #
      # This module only references that local image by name. To update the
      # app, rebuild the image, then: systemctl restart podman-artex
      # (no nixos-rebuild needed for app updates).
      #
      # First deploy:
      #   1. Create the database by hand (one time, on fdcc::3):
      #        sudo -u postgres createuser artex
      #        sudo -u postgres psql -c "ALTER USER artex PASSWORD '...'"
      #        sudo -u postgres createdb -O artex artex
      #   2. Put the password in the vaultix secret `artex` as:
      #        ARTEX_PG_DSN=postgres://artex:<password>@fdcc::3:5432/artex?sslmode=disable
      #        ANTHROPIC_API_KEY=...        # optional, can also be set in the UI
      #   3. Seed the skills bind mount (first deploy only):
      #        sudo mkdir -p /var/lib/artex/skills
      #        sudo cp -a ~/Src/ARTEX/skills/. /var/lib/artex/skills/

      vaultix.secrets.artex = { };

      virtualisation.oci-containers.containers.artex = {
        # Local image from the rootful podman store, built from ~/Src/ARTEX.
        image = "localhost/artex:local";

        # Host networking: the agent runs recon tools (nmap, masscan-style
        # scans, raw sockets) that need direct L3 access and see real source
        # addresses. Ports come from the binary flags, not port mappings:
        # web UI on :8787 (all interfaces), traffic proxy on 127.0.0.1:8788.
        extraOptions = [ "--network=host" ];

        volumes = [
          "/var/lib/artex/data:/app/data"
          "/var/lib/artex/skills:/app/skills"
        ];

        environmentFiles = [ config.vaultix.secrets.artex.path ];
      };

      networking.firewall.allowedTCPPorts = [ 8787 ];

      systemd.tmpfiles.rules = [
        "d /var/lib/artex 0755 root root - -"
        "d /var/lib/artex/data 0755 root root - -"
        "d /var/lib/artex/skills 0755 root root - -"
      ];
    };
}
