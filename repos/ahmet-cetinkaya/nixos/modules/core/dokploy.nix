{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [inputs.nix-dokploy.nixosModules.default];

  services.dokploy = {
    enable = true;
    database.passwordFile = "/var/lib/secrets/dokploy-db-password";
    auth.secretFile = "/var/lib/secrets/dokploy-auth-secret";
    encryption.keyFile = "/var/lib/secrets/dokploy-encryption-key";
  };

  networking.firewall.allowedTCPPorts = [80 443];

  # Akana: `tailscale serve` used to own the wildcard :443 listener, which
  # broke the upstream unit's `-p 443:443` recreate with "address already
  # in use" (2026-10-09 incident). Serve moved to :8443 on 2026-10-10, so
  # the wildcard is free again; the LAN-only 443 bind below is kept as
  # belt-and-braces (upstream `-p 443:443` would also work now). The custom
  # entrypoint ports are deliberately NOT declared here: they live in the
  # running container's publish set (Dokploy-managed state), not in NixOS.
  # After a unit restart recreates the container, restore them via
  # `settings-updateTraefikPorts` (native path, no sudo needed) — see
  # Homelab hosts/akana/docs/DOKPLOY-TROUBLESHOOTING.md.
  systemd.services.dokploy-traefik = {
    serviceConfig.ExecStart = let
      lanIpv4 = "192.168.1.2";
      startScript = pkgs.writeShellApplication {
        name = "dokploy-traefik-start-akana";
        runtimeInputs = [pkgs.docker];
        text = ''
          # Dokploy writes traefik.yml on first stack deploy; wait like the
          # upstream unit does.
          timeout=120
          while [ ! -f "${config.services.dokploy.dataDir}/traefik/traefik.yml" ]; do
            sleep 1
            timeout=$((timeout - 1))
            if [ "$timeout" -le 0 ]; then
              echo "Error: Timed out waiting for traefik.yml" >&2
              exit 1
            fi
          done

          if docker container inspect dokploy-traefik >/dev/null 2>&1; then
            echo "Starting existing Traefik container..."
            docker start dokploy-traefik
          else
            echo "Creating Traefik container with Akana port bindings..."
            docker run -d \
              --name dokploy-traefik \
              --network dokploy-network \
              --restart=always \
              -v /var/run/docker.sock:/var/run/docker.sock \
              -v ${config.services.dokploy.dataDir}/traefik/traefik.yml:/etc/traefik/traefik.yml \
              -v ${config.services.dokploy.dataDir}/traefik/dynamic:/etc/dokploy/traefik/dynamic \
              -p 80:80/tcp \
              -p ${lanIpv4}:443:443/tcp \
              -p ${lanIpv4}:443:443/udp \
              ${config.services.dokploy.traefik.image}
          fi
        '';
      };
    in lib.mkForce "${startScript}/bin/dokploy-traefik-start-akana";
  };
}
