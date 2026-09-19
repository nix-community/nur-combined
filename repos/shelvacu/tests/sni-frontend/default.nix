{
  pkgs,
  nodes,
  vacuRoot,
  vacuModules,
  ...
}:
let
  certs = import /${vacuRoot}/deterministic-certs.nix { nixpkgs = pkgs; };
  localDomain = "local.test";
  passthroughDomain = "passthru.test";

  rootCA = certs.selfSigned "sni-test-ca" {
    ca = true;
    cert_signing_key = true;
    cn = "SNI frontend test CA";
  };
  certFor = name: domain:
    certs.caSigned name rootCA {
      ca = false;
      signing_key = true;
      encryption_key = true;
      tls_www_client = true;
      tls_www_server = true;
      cn = domain;
      dns_name = domain;
    };
  localCert = certFor "sni-test-local" localDomain;
  passthroughCert = certFor "sni-test-passthrough" passthroughDomain;
in
{
  name = "sni-frontend";

  defaults = {
    security.pki.certificateFiles = [ rootCA.certificatePath ];
    networking.hosts = {
      ${nodes.front.networking.primaryIPAddress} = [ localDomain passthroughDomain ];
    };
  };

  # The machine with the public address. It serves local.test itself and hands
  # passthru.test to the backend without decrypting it.
  nodes.front = { ... }: {
    imports = [ vacuModules.sni-frontend ];

    vacu.sniFrontend = {
      enable = true;
      passthrough.${passthroughDomain} = "backend:443";
    };

    services.caddy = {
      enable = true;
      virtualHosts.${localDomain}.extraConfig = ''
        tls ${localCert.certificatePath} ${localCert.privateKeyPath}
        # Echoes who Caddy thinks the client is, which is the whole point of
        # carrying the PROXY header across the socket.
        respond "front {http.request.remote.host}"
      '';
    };
  };

  # Stands in for a host that owns a name but has no public address of its own.
  # It is reachable both ways: relayed by the front door, and directly by any
  # client that can address it — so its listener has to expect a PROXY header
  # from the front door without demanding one from everybody else.
  nodes.backend = { nodes, ... }: {
    networking.firewall.allowedTCPPorts = [ 443 ];
    services.caddy = {
      enable = true;
      globalConfig = ''
        servers :443 {
          listener_wrappers {
            proxy_protocol {
              allow ${nodes.front.networking.primaryIPAddress}/32
            }
            tls
          }
        }
      '';
      virtualHosts.${passthroughDomain}.extraConfig = ''
        tls ${passthroughCert.certificatePath} ${passthroughCert.privateKeyPath}
        respond "backend {http.request.remote.host}"
      '';
    };
  };

  nodes.client = { ... }: {
    environment.systemPackages = [ pkgs.curlHTTP3 ];
  };

  testScript = ''
    start_all()

    backend.wait_for_unit("caddy.service")
    backend.wait_for_open_port(443)
    front.wait_for_unit("caddy.service")
    front.wait_for_unit("nginx.service")
    front.wait_for_open_port(443)
    client.wait_for_unit("multi-user.target")

    client_ip = "${nodes.client.networking.primaryIPAddress}"

    with subtest("unmatched names are served by the local Caddy"):
        out = client.succeed("curl -sS --fail https://${localDomain}/")
        assert out.startswith("front "), f"expected the front Caddy to answer, got {out!r}"

    with subtest("the local Caddy sees the real client, not the front door"):
        served_ip = client.succeed("curl -sS --fail https://${localDomain}/").split()[1]
        assert served_ip == client_ip, f"expected client {client_ip}, Caddy saw {served_ip}"

    with subtest("a passthrough name is answered by the backend"):
        out = client.succeed("curl -sS --fail https://${passthroughDomain}/")
        assert out.startswith("backend "), f"expected the backend to answer, got {out!r}"

    with subtest("the backend sees the real client through the relay"):
        served_ip = client.succeed("curl -sS --fail https://${passthroughDomain}/").split()[1]
        assert served_ip == client_ip, f"expected client {client_ip}, backend saw {served_ip}"

    with subtest("the backend still serves clients that reach it directly"):
        # Its own address stays usable — only traffic arriving from the front
        # door carries a PROXY header, and demanding one from everybody would
        # break every client that can address the backend itself.
        backend_ip = "${nodes.backend.networking.primaryIPAddress}"
        out = client.succeed(
            f"curl -sS --fail --resolve ${passthroughDomain}:443:{backend_ip}"
            " https://${passthroughDomain}/"
        )
        assert out.startswith("backend "), f"direct request failed: {out!r}"

    with subtest("passthrough is not re-terminated: the backend's own cert arrives"):
        # Proves the connection was relayed rather than decrypted and re-encrypted
        # — the front door has no key for this name at all.
        subject = client.succeed(
            "curl -sS --fail -w '%{certs}' -o /dev/null https://${passthroughDomain}/"
            " | grep -i '^Subject:'"
        )
        assert "${passthroughDomain}" in subject, f"unexpected certificate {subject!r}"

    with subtest("the front door holds no key for the passthrough name"):
        front.fail("grep -rq '${passthroughDomain}' /var/lib/caddy 2>/dev/null")

    with subtest("HTTP/3 is given up, and clients fall back on their own"):
        # Pinning the known cost of the socket: it carries no UDP, so QUIC has
        # nowhere to land. Clients negotiate this themselves, so the same
        # request succeeds the moment HTTP/3 is not demanded.
        client.fail("curl -sS --fail --http3-only https://${localDomain}/")
        out = client.succeed("curl -sS --fail https://${localDomain}/")
        assert out.startswith("front "), f"fallback request failed: {out!r}"

    with subtest("plain HTTP is still served, so redirects and ACME keep working"):
        # Only TLS moved to the socket. Port 80 has no server name to route on
        # and no reason to be relayed, so Caddy keeps it directly.
        code = client.succeed(
            "curl -sS -o /dev/null -w '%{http_code}' http://${localDomain}/"
        )
        assert code.startswith("30"), f"expected a redirect from port 80, got {code}"
  '';
}
