{
  flake.modules.nixos.nginx = {
    services.nginx = {
      enable = true;
      clientMaxBodySize = "4G";
      virtualHosts = {
        "s3.nyaw.xyz" = {
          forceSSL = true;
          sslCertificate = "/run/credentials/nginx.service/nyaw.cert";
          sslCertificateKey = "/run/credentials/nginx.service/nyaw.key";
          locations = {
            "/" = {
              proxyPass = "http://localhost:9000";
              extraConfig = ''
                proxy_set_header Host $host;
                proxy_set_header X-Real-IP $remote_addr;
                proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                proxy_set_header X-Forwarded-Proto $scheme;

                proxy_connect_timeout 300;
                proxy_http_version 1.1;
                proxy_set_header Connection "";
                chunked_transfer_encoding off;
              '';
            };
          };
        };
      };
    };
  };
}
