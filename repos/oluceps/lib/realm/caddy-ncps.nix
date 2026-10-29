{
  listen ? "127.0.0.1:18502",
  socket ? "/run/realm/nix-cache/egress/ncps.sock",
}:
let
  denied = {
    handler = "static_response";
    status_code = 403;
  };
in
{
  admin.disabled = true;
  apps.http.servers.ncps = {
    listen = [ listen ];
    automatic_https.disable = true;
    max_header_bytes = 16384;
    routes = [
      {
        # Inspect the original request target before Caddy's path matchers clean
        # it. Cache object names need no escaping: reject encoded paths outright,
        # including double encoding, encoded separators and encoded dot segments.
        # Query strings may contain escapes and are not part of the path policy.
        match = [
          {
            expression = ''{http.request.orig_uri}.matches(r'^[^?]*[%\\]|^[^?]*//|^/([^?]*/)?[.]{1,2}(/|[?]|$)')'';
          }
          {
            path = [
              "/metrics*"
              "/debug*"
            ];
          }
        ];
        handle = [ denied ];
        terminal = true;
      }
      {
        match = [
          {
            method = [
              "GET"
              "HEAD"
            ];
          }
        ];
        handle = [
          {
            handler = "reverse_proxy";
            upstreams = [ { dial = "unix/${socket}"; } ];
            transport = {
              protocol = "http";
              dial_timeout = "5s";
            };
          }
        ];
        terminal = true;
      }
      {
        handle = [ denied ];
        terminal = true;
      }
    ];
  };
}
