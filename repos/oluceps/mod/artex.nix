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
      #   1. Create the database and role by hand (one time, on the host that
      #      runs PostgreSQL):
      #        sudo -u postgres createuser artex
      #        sudo -u postgres createdb -O artex artex
      #      No password: connections arrive through the realm egress below and
      #      PostgreSQL maps the ingress peer user to the artex role (identMap
      #      `realm-artex`, see mod/postgresql.nix).
      #   2. Put the remaining runtime secrets in the vaultix secret `artex`:
      #        ANTHROPIC_API_KEY=...        # optional, can also be set in the UI
      #   3. Seed the skills bind mount (first deploy only):
      #        sudo mkdir -p /var/lib/artex/skills
      #        sudo cp -a ~/Src/ARTEX/skills/. /var/lib/artex/skills/

      vaultix.secrets.artex = { };

      # Database access goes through the authenticated realm egress instead of
      # a TCP connection with a password. The container is host-networked (see
      # extraOptions below), so it cannot use the namespace-local loopback
      # adapters; it mounts the egress socket and pgx dials the Unix socket.
      realm.workloads.artex = {
        unit = "podman-artex.service";
        # Rootful Podman with --network=host keeps the raw L3 access the recon
        # tools need, so the workload is not sandboxed in a private namespace.
        runtime = "external";
        isolation.privateNetwork = false;
        # PostgreSQL names its Unix socket .s.PGSQL.<port>, which is exactly
        # what a libpq-style `host=<dir>` DSN expects.
        egress.postgresql = {
          service = "postgresql-artex";
          socket = "/run/realm/artex/egress/.s.PGSQL.5432";
        };
      };

      # The container mounts the egress directory, so the listening socket must
      # exist before Podman creates the mount namespace.
      systemd.services.podman-artex = {
        requires = [ "realm-egress-artex-postgresql.socket" ];
        after = [ "realm-egress-artex-postgresql.socket" ];
      };

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
          "/run/realm/artex/egress:/realm/egress:ro"
        ];

        environmentFiles = [ config.vaultix.secrets.artex.path ];

        # No password: the egress proxy authenticates the workload with its
        # SPIFFE identity and the ingress peer-maps it to the artex role.
        environment.ARTEX_PG_DSN = "postgres://artex@/artex?host=/realm/egress&port=5432&sslmode=disable";
      };

      networking.firewall.allowedTCPPorts = [ 8787 ];

      systemd.tmpfiles.rules = [
        "d /var/lib/artex 0755 root root - -"
        "d /var/lib/artex/data 0755 root root - -"
        "d /var/lib/artex/skills 0755 root root - -"
      ];
    };
}
