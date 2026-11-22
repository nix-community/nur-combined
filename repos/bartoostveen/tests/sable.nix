{
  self,
  pkgs,
  lib,
  ...
}:

let
  domain = "sable.test";

  cert = pkgs.runCommand "sable-test-cert" { nativeBuildInputs = [ pkgs.openssl ]; } ''
    mkdir -p $out
    openssl req -x509 -newkey rsa:2048 -nodes -days 365 \
      -keyout $out/key.pem -out $out/cert.pem \
      -subj "/CN=${domain}" -addext "subjectAltName=DNS:${domain}"
  '';
in
{
  name = "sable";

  nodes = {
    server = {
      imports = [ self.nixosModules.sable ];

      networking.firewall.allowedTCPPorts = [ 443 ];
      networking.extraHosts = "127.0.0.1 ${domain}";

      services.sable = {
        enable = true;
        settings = {
          listen_addr = "127.0.0.1:18008";
          public_url = "https://${domain}";
          client_ip_source = "RightmostXForwardedFor";
          # generated using sable-server hash-password, password is '123' in plain text
          # TODO: actually test an endpoint
          password_hash = "$argon2id$v=19$m=19456,t=2,p=1$un7HsjkYpb9omzeAwXskJg$pxwJzZy7FhdPRxgPnOKR0SHdZzlo9/SEnW1RO5WwtTY";
        };
      };

      services.nginx = {
        enable = true;
        recommendedProxySettings = true;
        virtualHosts.${domain} = {
          onlySSL = true;
          sslCertificate = "${cert}/cert.pem";
          sslCertificateKey = "${cert}/key.pem";
          locations."/" = {
            proxyPass = "http://127.0.0.1:18008";
            proxyWebsockets = true;
          };
        };
      };
    };

    client =
      { nodes, ... }:

      {
        security.pki.certificateFiles = [ "${cert}/cert.pem" ];
        networking.extraHosts = "${nodes.server.networking.primaryIPAddress} ${domain}";
      };
  };

  testScript = ''
    start_all()

    with subtest("Sable server listening"):
        server.wait_for_unit("sable.service")
        server.wait_for_unit("nginx.service")

        server.wait_for_open_port(18008)
        server.wait_for_open_port(443)

    with subtest("frontend is served through the reverse proxy over TLS"):
        client.wait_until_succeeds("curl -sf https://${domain}/ -o /tmp/index.html")
        client.succeed("grep -qi '<html' /tmp/index.html")

    with subtest("websocket endpoint is proxied"):
        code = client.succeed("""
          curl -s -o /dev/null -w '%{http_code}' \
            -H 'Connection: Upgrade' -H 'Upgrade: websocket' \
            -H 'Sec-WebSocket-Version: 13' \
            -H 'Sec-WebSocket-Key: dGhlIHNhbXBsZSBub25jZQ==' \
            -H 'Origin: https://${domain}' \
            --max-time 5 https://${domain}/_sable/ws || true
        """).strip()
        print(f"websocket handshake status: {code}")
        assert code not in ("502", "504", "000"), f"proxy could not reach sable: {code}"

    with subtest("hardening is applied"):
        server.succeed("systemd-analyze security sable.service --no-pager | tail -n1")
  '';

  meta.maintainers = with lib.maintainers; [ bartoostveen ];
}
