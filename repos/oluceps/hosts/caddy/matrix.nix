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

        {
          handle = [
            (
              let
                conf = {
                  defaultHomeserver = 0;
                  homeserverList = [
                    "nyaw.xyz"
                    "envs.net"
                    "matrix.org"
                    "monero.social"
                    "mozilla.org"
                    "nichi.co"
                  ];
                };
              in
              {
                handler = "vars";
                root = pkgs.cinny.override { inherit conf; };
              }
            )
          ];
        }
        {
          handle = [
            {
              handler = "rewrite";
              uri = "{http.matchers.file.relative}";
            }
          ];
          match = [
            {
              file = {
                try_files = [
                  "{http.request.uri.path}"
                  "/"
                  "index.html"
                ];
              };
            }
          ];
        }
        {
          handle = [

            {
              handler = "headers";
              response.set = {
                X-Frame-Options = [ "SAMEORIGIN" ];
                X-Content-Type-Options = [ "nosniff" ];
                X-XSS-Protection = [ "1; mode=block" ];
                Content-Security-Policy = [ "frame-ancestors 'self'" ];
              };
            }
            {
              handler = "file_server";
            }
          ];
        }

      ];
    }

  ];
  match = [ { host = [ "matrix.nyaw.xyz" ]; } ];
  terminal = true;
}
