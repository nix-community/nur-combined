{
  handle = [
    {
      handler = "subroute";
      routes = [
        {
          handle = [
            (import ./nyaw-xyz-matrix-wellknown.nix)
            {
              handler = "reverse_proxy";
              upstreams = [ { dial = "unix//run/realm/caddy/egress/misskey.sock"; } ];
            }
          ];
          match = [ { host = [ "nyaw.xyz" ]; } ];
          terminal = true;
        }
      ];
    }
  ];
  match = [ { host = [ "nyaw.xyz" ]; } ];
  terminal = true;
}
