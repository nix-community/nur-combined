{ lib, config, ... }:
{
  repack.caddy = {
    enable = true;
    settings = {
      apps = {
        http.grace_period = "1s";
        http = {
          servers = {
            srv0 = {
              routes = [

              ];
            };
          };
        };
      };
    };
  };
}
