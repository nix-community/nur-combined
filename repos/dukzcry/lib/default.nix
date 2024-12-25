{ pkgs }:

with pkgs.lib; {
  # Add your library functions here
  #
  # hexint = x: hexvals.${toLower x};
  lists = rec {
    foldmap = seed: acc: func: list:
      let
        acc' = if acc == [] then [seed] else acc;
        x = head list;
        xs = tail list;
      in if list == [] then acc
         else acc ++ (foldmap seed [(func x acc')] func xs);
  };
  mkAfterAfter = mkOrder 1600;
  page = { name, protocol ? "http", port, attrs ? {}, hasWidget ? true, hasSiteMonitor ? false, path ? "", description ? "", networking, ... }:
    {
      "${name}" = rec {
        href = "http://${name}.${networking.fqdn}/${path}";
        icon = attrs.alticon or "${name}.png";
        siteMonitor = optionalString hasSiteMonitor "${protocol}://127.0.0.1:${toString port}";
        inherit description;
      } // (optionalAttrs hasWidget {
        widget = {
          type = name;
          url = "${protocol}://127.0.0.1:${toString port}";
        } // attrs;
      });
    };
  nginx = { name, protocol ? "http", port, websockets ? false, networking, ... }:
    {
      "${name}.${networking.hostName}" = {
        serverAliases = [ "${name}.${networking.fqdn}" ];
        locations."/" = {
          proxyPass = "${protocol}://127.0.0.1:${toString port}";
          proxyWebsockets = websockets;
        };
      };
    };
}
