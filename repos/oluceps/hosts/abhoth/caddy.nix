{
  pkgs,
  lib,
  config,
  ...
}:
{

  repack.caddy = {
    enable = true;
    public = true;
    settings.apps.http.servers = {
      srv0 = {
        routes = [
          # {
          #   handle = [
          #     {
          #       handler = "subroute";
          # routes = [
          (import ../caddy-matrix.nix {
            inherit pkgs;
            matrix-upstream = "[fdcc::3]:6167";
          })
          #       ];
          #     }
          #   ];
          #   match = [ { host = [ "*.nyaw.xyz" ]; } ];
          # }
        ];
      };
    };
  };
}
