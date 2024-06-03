let
  modules = {
    networking = {
      netns = import ./networking/netns.nix;
    };
    services = {
      pueue = import ./services/pueue.nix;
      qbittorrent = import ./services/qbittorrent.nix;
    };
  };

  inherit (builtins) attrValues;
  concat = lists:
    builtins.foldl' (acc: elem: acc ++ elem) [ ] lists;

  all-modules = concat [
    (attrValues modules.networking)
    (attrValues modules.services)
  ];
in modules // {
  inherit all-modules;
}
