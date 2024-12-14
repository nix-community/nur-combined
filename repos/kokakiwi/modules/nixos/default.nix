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
      sccache = ./services/sccache.nix;
      vanta-agent = ./services/vanta-agent.nix;
    };
  };

  all-modules = lib.concatLists [
    (lib.attrValues modules.networking)
    (lib.attrValues modules.services)
  ];
in modules // {
  inherit all-modules;
}
