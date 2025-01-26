{ lib, config, ... }:
{
  repack.reuse-cert.enable = true;
  repack.caddy = {
    enable = true;
    settings.apps = {
      http.servers.srv0.routes = [
        {
          handle = [
            {
              handler = "reverse_proxy";
              upstreams = [ { dial = "localhost:9000"; } ];
            }
          ];
          match = [ { host = [ "s3.nyaw.xyz" ]; } ];
        }
        {
          handle = [
            {
              handler = "reverse_proxy";
              upstreams = [ { dial = "localhost:2283"; } ];
            }
          ];
          match = [ { host = [ "photo.nyaw.xyz" ]; } ];
        }
      ];

      tls.automation.policies = [
        {
          subjects = [
            "*.nyaw.xyz"
          ];
          issuers = [
            {
              module = "acme";
              challenges = {
                dns = {
                  provider = {
                    name = "porkbun";
                    api_key = "{env.PORKBUN_API_KEY}";
                    api_secret_key = "{env.PORKBUN_API_SECRET_KEY}";
                  };
                };
              };
            }
          ];
        }
      ];
    };
  };
}
