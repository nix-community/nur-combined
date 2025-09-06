{ lib, ... }:
let
  modules = {
    networking = {
      netns = ./networking/netns.nix;
      shadowsocks-rust = ./networking/shadowsocks-rust.nix;
    };
    services = {
      edgee = ./services/edgee.nix;
      iocaine = ./services/iocaine.nix;
      linx-server = ./services/linx-server.nix;
      ots = ./services/ots.nix;
      pueue = ./services/pueue.nix;
      safetwitch = ./services/safetwitch.nix;
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
