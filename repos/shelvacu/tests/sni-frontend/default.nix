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
  plainDomain = "plain.test";
  # A whole zone handed over by wildcard, and the bare name of that zone, which
  # the wildcard deliberately does not cover.
  wildcardName = "*.wild.test";
  wildcardSub = "sub.wild.test";
  wildcardApex = "wild.test";
  # The other mask: a whole zone, bare name included, which is what a host
  # handing its zone to another machine actually wants.
  zoneName = ".zone.test";
  zoneApex = "zone.test";
  zoneDeep = "deep.sub.zone.test";

  rootCA = certs.selfSigned "sni-test-ca" {
    ca = true;
    cert_signing_key = true;
    cn = "SNI frontend test CA";
  };
  certFor =
    name: domain:
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
  wildcardSubCert = certFor "sni-test-wildcard-sub" wildcardSub;
  wildcardApexCert = certFor "sni-test-wildcard-apex" wildcardApex;
  zoneApexCert = certFor "sni-test-zone-apex" zoneApex;
  zoneDeepCert = certFor "sni-test-zone-deep" zoneDeep;
in
{
  name = "sni-frontend";

  defaults = {
    security.pki.certificateFiles = [ rootCA.certificatePath ];
    networking.hosts = {
      ${nodes.front.networking.primaryIPAddress} = [
        localDomain
        passthroughDomain
        plainDomain
        wildcardSub
        wildcardApex
        zoneApex
        zoneDeep
      ];
    };
  };

  # The machine with the public address. It serves local.test itself and hands
  # passthru.test to the backend without decrypting it.
  nodes.front = { config, ... }: {
    imports = [ vacuModules.sni-frontend ];

    vacu.sniFrontend = {
      enable = true;
      passthrough = {
        ${passthroughDomain} = "backend:443";
        ${wildcardName} = "backend:443";
        ${zoneName} = "backend:443";
      };
    };

    services.caddy = {
      enable = true;
      virtualHosts.${localDomain}.extraConfig = ''
        tls ${localCert.certificatePath} ${localCert.privateKeyPath}
        # Echoes who Caddy thinks the client is, which is the whole point of
        # carrying the PROXY header across the socket.
        respond "front {http.request.remote.host}"
      '';
      # The bare name of the wildcarded zone, served here to prove the wildcard
      # left it behind rather than swallowing it.
      virtualHosts.${wildcardApex}.extraConfig = ''
        tls ${wildcardApexCert.certificatePath} ${wildcardApexCert.privateKeyPath}
        respond "front {http.request.remote.host}"
      '';
      # A site of this host's own that is served over plain HTTP, next to the
      # HTTPS one above. Caddy will not put the two on one listener, so this is
      # what httpBind is for — and a site that forgets it does not fail alone,
      # it stops the whole Caddyfile from adapting.
      virtualHosts."http://${plainDomain}".extraConfig = ''
        bind ${config.vacu.sniFrontend.httpBind}
        respond "plain {http.request.remote.host}"
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
      virtualHosts.${wildcardSub}.extraConfig = ''
        tls ${wildcardSubCert.certificatePath} ${wildcardSubCert.privateKeyPath}
        respond "backend {http.request.remote.host}"
      '';
      virtualHosts.${zoneApex}.extraConfig = ''
        tls ${zoneApexCert.certificatePath} ${zoneApexCert.privateKeyPath}
        respond "backend {http.request.remote.host}"
      '';
      virtualHosts.${zoneDeep}.extraConfig = ''
        tls ${zoneDeepCert.certificatePath} ${zoneDeepCert.privateKeyPath}
        respond "backend {http.request.remote.host}"
      '';
    };
  };

  nodes.client = { ... }: { environment.systemPackages = [ pkgs.curlHTTP3 ]; };

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

    with subtest("a wildcard name relays every label under it"):
        out = client.succeed("curl -sS --fail https://${wildcardSub}/")
        assert out.startswith("backend "), f"expected the backend to answer, got {out!r}"

    with subtest("a wildcard does not cover the bare name of its zone"):
        # nginx matches these keys like a server_name, so `*.wild.test` leaves
        # `wild.test` to the default — which is the trap the leading-dot form
        # below exists to avoid.
        out = client.succeed("curl -sS --fail https://${wildcardApex}/")
        assert out.startswith("front "), f"expected the front Caddy to answer, got {out!r}"

    with subtest("a leading dot hands over the bare name too"):
        out = client.succeed("curl -sS --fail https://${zoneApex}/")
        assert out.startswith("backend "), f"expected the backend to answer, got {out!r}"

    with subtest("a leading dot hands over the zone however deep"):
        out = client.succeed("curl -sS --fail https://${zoneDeep}/")
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
        # Binding Caddy's sites to a socket takes its HTTP server with them, so
        # port 80 is relayed to a socket of its own. Nothing routes by name
        # there — it is a straight copy — but the redirect has to survive it.
        code = client.succeed(
            "curl -sS -o /dev/null -w '%{http_code}' http://${localDomain}/"
        )
        assert code.startswith("30"), f"expected a redirect from port 80, got {code}"

    with subtest("a site of this host's own can be served over plain HTTP"):
        # The generated redirect is a catch-all, so a name with a site of its
        # own has to win over it rather than bounce to a URL with no HTTPS
        # behind it.
        out = client.succeed("curl -sS --fail http://${plainDomain}/")
        assert out.startswith("plain "), f"expected the plain-HTTP site, got {out!r}"

    with subtest("the plain-HTTP relay carries the client address too"):
        served_ip = client.succeed("curl -sS --fail http://${plainDomain}/").split()[1]
        assert served_ip == client_ip, f"expected client {client_ip}, Caddy saw {served_ip}"
  '';
}
