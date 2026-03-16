{
  handle = [
    {
      handler = "subroute";
      routes = [
        {
          handle = [
            {
              handler = "reverse_proxy";
              transport = {
                protocol = "http";
                tls = {
                  server_name = "nyaw.xyz";
                };
              };
              upstreams = [ { dial = "[fdcc::3]:443"; } ];
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
