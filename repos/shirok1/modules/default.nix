{
  importApply,
  localFlake,
  withSystem,
}:

{
  edk2-cix = importApply ./edk2-cix.nix { inherit localFlake withSystem; };
  futu-opend = importApply ./futu-opend.nix { inherit localFlake withSystem; };
  msd-lite = importApply ./msd-lite.nix { inherit localFlake withSystem; };
  osmo-fl2k = importApply ./osmo-fl2k.nix { inherit localFlake withSystem; };
  peerbanhelper = importApply ./peerbanhelper.nix { inherit localFlake withSystem; };
  qbittorrent-clientblocker = importApply ./qbittorrent-clientblocker.nix {
    inherit localFlake withSystem;
  };
  snell-server = importApply ./snell-server.nix { inherit localFlake withSystem; };
  teamspeak6-server = importApply ./teamspeak6-server.nix { inherit localFlake withSystem; };
  tcp-brutal = importApply ./tcp-brutal.nix { inherit localFlake withSystem; };
}
