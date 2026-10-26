{
  basicAuthAccounts ? null,
}:
{
  match = [ { host = [ "photo.nyaw.xyz" ]; } ];
  handle = [
    {
      handler = "subroute";
      routes = [
        {
          match = [
            {
              path = [
                "/share"
                "/share/*"
              ];
            }
          ];
          handle = [
            {
              handler = "reverse_proxy";
              upstreams = [ { dial = "unix//run/realm/caddy/egress/immich-public-proxy.sock"; } ];
            }
          ];
          terminal = true;
        }
        {
          handle =
            (
              if basicAuthAccounts == null then
                [ ]
              else
                [
                  {
                    handler = "authentication";
                    providers.http_basic.accounts = basicAuthAccounts;
                  }
                ]
            )
            ++ [
              {
                handler = "reverse_proxy";
                upstreams = [ { dial = "unix//run/realm/caddy/egress/immich.sock"; } ];
              }
            ];
          terminal = true;
        }
      ];
    }
  ];
  terminal = true;
}
