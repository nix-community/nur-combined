let
  nginxExporterPort = 9113;
  prometheusPort = 9090;
in
import ./lib/make-test.nix (
  { pkgs, ... }:
  let
    runWithOpenSSL = file: cmd: pkgs.runCommand
      file
      {
        buildInputs = [ pkgs.openssl ];
      }
      cmd;

    keyBitSize = 1024; # probably unwise in production, but faster in tests
    key = runWithOpenSSL "key.pem" ''
      openssl genrsa -out $out ${toString keyBitSize}
    '';
    csr = runWithOpenSSL "csr.csr" ''
      openssl req -new -sha256 -key ${key} -out $out -subj "/CN=localhost"
    '';
    cert = runWithOpenSSL "cert.pem" ''
      openssl req -x509 -sha256 -days 365 -key ${key} -in ${csr} -out $out
    '';
  in
  {
    name = "nginx";
    nodes.nginx = {
      environment.systemPackages = with pkgs; [ openssl jq ];

      priegger.services.nginx.enable = true;
      security.dhparams.defaultBitSize = 128; # probably unwise in production, but faster in tests
      services.nginx.virtualHosts.default = {
        default = true;
        forceSSL = true;

        sslCertificate = cert;
        sslCertificateKey = key;
      };

      services.prometheus.enable = true;
    };

    testScript =
      ''
        nginx.wait_for_unit("nginx.service")
        nginx.wait_for_open_port(80)
        nginx.wait_for_open_port(443)

        nginx.succeed(
            "test -s /var/lib/dhparams/nginx.pem",
            "echo | openssl s_client localhost:443",
            "curl localhost:80/nginx_status",
        )

        nginx.wait_for_unit("prometheus-nginx-exporter.service")
        nginx.wait_for_open_port(9113)

        nginx.succeed(
            "curl -s http://127.0.0.1:${toString nginxExporterPort}/metrics"
            + " | grep -q 'nginxexporter_build_info{.\\+} 1'"
        )
        nginx.wait_until_succeeds(
            "curl -sf 'http://127.0.0.1:${toString prometheusPort}/api/v1/query?query=nginxexporter_build_info' | "
            + "jq '.data.result[0].value[1]' | grep '\"1\"'"
        )
      '';
  }
)
