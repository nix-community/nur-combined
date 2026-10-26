# CORS for the dn42 autopeer ingress hosts.
#
# Browsers talking to these hosts from another origin send a preflight first;
# Caddy answers it here instead of leaving it to the upstream. Real responses
# get the same header set, replacing whatever the backend sent. Requests
# without an Origin header are proxied untouched, with no CORS headers.
{
  hosts,
  upstream ? "unix//run/realm/caddy/egress/autopeer.sock",
}:
let
  # Headers every CORS response needs.
  corsHeaders = {
    # Reflect the caller origin so the same block works for any dn42 web client.
    Access-Control-Allow-Origin = [ "{http.request.header.Origin}" ];
    Access-Control-Allow-Methods = [
      "GET"
      "POST"
      "UPDATE"
      "DELETE"
      "OPTIONS"
    ];
    Access-Control-Expose-Headers = [ "X-Request-Id" ];
    Vary = [ "Origin" ];
  };

  # Headers only a preflight answer needs.
  preflightHeaders = {
    Access-Control-Allow-Headers = [ "{http.request.header.Access-Control-Request-Headers}" ];
    Access-Control-Max-Age = [ "86400" ];
  };

  proxy = {
    handler = "subroute";
    routes = [
      {
        # Answer the preflight locally; it never reaches the upstream.
        # A bare OPTIONS (no Origin) is not a preflight and goes upstream.
        match = [
          {
            method = [ "OPTIONS" ];
            header.Origin = [ "*" ];
          }
        ];
        handle = [
          {
            handler = "headers";
            response.set = preflightHeaders;
          }
          {
            handler = "static_response";
            status_code = 204;
          }
        ];
        terminal = true;
      }
      {
        handle = [
          {
            handler = "reverse_proxy";
            upstreams = [ { dial = upstream; } ];
          }
        ];
      }
    ];
  };
in
{
  match = [ { host = hosts; } ];
  handle = [
    {
      handler = "subroute";
      routes = [
        {
          match = [ { header.Origin = [ "*" ]; } ];
          handle = [
            {
              handler = "headers";
              response.set = corsHeaders;
            }
            proxy
          ];
          terminal = true;
        }
        {
          handle = [ proxy ];
          terminal = true;
        }
      ];
    }
  ];
  terminal = true;
}
