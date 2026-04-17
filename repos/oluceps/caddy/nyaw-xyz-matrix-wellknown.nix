{
  handler = "subroute";
  routes = [
    {
      handle = [
        {
          handler = "headers";
          response = {
            set = {
              Access-Control-Allow-Origin = [ "*" ];
            };
          };
        }
      ];
      match = [ { path = [ "/.well-known/matrix/*" ]; } ];
    }
    {
      handle = [
        {
          body = builtins.toJSON { "m.server" = "matrix.nyaw.xyz:443"; };
          handler = "static_response";
        }
      ];
      match = [ { path = [ "/.well-known/matrix/server" ]; } ];
    }
    {
      handle = [
        {
          body = builtins.toJSON {
            "m.server" = {
              base_url = "https://matrix.nyaw.xyz";
            };
            "m.homeserver" = {
              base_url = "https://matrix.nyaw.xyz";
            };
            "org.matrix.msc3575.proxy" = {
              url = "https://matrix.nyaw.xyz";
            };
          };
          handler = "static_response";
        }
      ];
      match = [ { path = [ "/.well-known/matrix/client" ]; } ];
    }
  ];
}
