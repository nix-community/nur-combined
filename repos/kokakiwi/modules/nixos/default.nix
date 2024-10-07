{ lib, ... }:
let
  modules = {
    networking = {
      netns = ./networking/netns.nix;
      shadowsocks-rust = ./networking/shadowsocks-rust.nix;
    };
    services = {
      pueue = ./services/pueue.nix;
      qbittorrent = ./services/qbittorrent.nix;
    };
  };

  all-modules = lib.concat [
    (lib.attrValues modules.networking)
    (lib.attrValues modules.services)
  ];
in modules // {
  inherit all-modules;
}
