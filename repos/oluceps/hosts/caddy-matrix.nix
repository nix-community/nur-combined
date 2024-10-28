{ pkgs, matrix-upstream, ... }:
{
  handle = [
    {
      handler = "subroute";
      routes = [
        {
          handle = [
            {
              handler = "reverse_proxy";
              upstreams = [ { dial = matrix-upstream; } ];
            }
          ];
          match = [
            {
              path = [ "/_matrix/*" ];
            }
          ];
          terminal = true;
        }
      ];
    }

    {
      handler = "headers";
      response.set = {
        X-Frame-Options = [ "SAMEORIGIN" ];
        X-Content-Type-Options = [ "nosniff" ];
        X-XSS-Protection = [ "1; mode=block" ];
        Content-Security-Policy = [ "frame-ancestors 'self'" ];
      };
    }
    (
      let
        conf = {
          default_server_config = {
            "m.homeserver" = {
              base_url = "https://matrix.nyaw.xyz";
              server_name = "nyaw.xyz";
            };
          };
          show_labs_settings = true;
        };
      in
      {
        handler = "file_server";
        root = "${pkgs.element-web.override { inherit conf; }}";
      }
    )
  ];
  match = [ { host = [ "matrix.nyaw.xyz" ]; } ];
  terminal = true;
}
