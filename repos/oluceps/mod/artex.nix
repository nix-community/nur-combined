{
  flake.modules.nixos.artex =
    { config, pkgs, ... }:
    {
      # containerfile-nix executes the pinned upstream Dockerfile.safe in a VM.
      # The image retains upstream's Debian base, tools and startup defaults.
      # Build with: nix build .#artex-image -L --option sandbox relaxed --builders ""
      # Output: result/artex.tar (loaded automatically through imageFile).
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
      # Built-in skills are seeded from the pinned source when the skills
      # directory is empty. The JWT signing key has a separate persistent mount.

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
        path = [
          pkgs.coreutils
          pkgs.findutils
        ];
        preStart = ''
          if [ -z "$(find /var/lib/artex/skills -mindepth 1 -maxdepth 1 -print -quit)" ]; then
            cp -r ${pkgs.artex-image.src}/skills/. /var/lib/artex/skills/
            chmod -R u+w /var/lib/artex/skills
          fi
        '';
        requires = [ "realm-egress-artex-postgresql.socket" ];
        after = [ "realm-egress-artex-postgresql.socket" ];
      };

      virtualisation.oci-containers.containers.artex = {
        image = "localhost/${pkgs.artex-image.imageName}:${pkgs.artex-image.imageTag}";
        imageFile = "${pkgs.artex-image}/artex.tar";

        # Host networking: the agent runs recon tools (nmap, masscan-style
        # scans, raw sockets) that need direct L3 access and see real source
        # addresses. Ports come from the binary flags, not port mappings:
        # web UI on :8787, traffic proxy on :8788 (upstream image defaults).
        extraOptions = [
          "--network=host"
          "--shm-size=1g"
        ];

        volumes = [
          "/var/lib/artex/data:/app/data"
          "/var/lib/artex/keys:/app/keys"
          "/var/lib/artex/skills:/app/skills"
          "/run/realm/artex/egress:/realm/egress:ro"
        ];

        environmentFiles = [ config.vaultix.secrets.artex.path ];

        # No password: the egress proxy authenticates the workload with its
        # SPIFFE identity and the ingress peer-maps it to the artex role.
        environment.ARTEX_PG_DSN = "postgres://artex@/artex?host=/realm/egress&port=5432&sslmode=disable";
      };

      # networking.firewall.allowedTCPPorts = [ 8787 ];

      systemd.tmpfiles.rules = [
        "d /var/lib/artex 0755 root root - -"
        "d /var/lib/artex/data 0755 root root - -"
        "d /var/lib/artex/keys 0700 root root - -"
        "d /var/lib/artex/skills 0755 root root - -"
      ];
    };
}
