{ importApply, localFlake, withSystem }:

{
  msd-lite = importApply ./msd-lite.nix { inherit localFlake withSystem; };
  peerbanhelper = importApply ./peerbanhelper.nix { inherit localFlake withSystem; };
  qbittorrent-clientblocker = importApply ./qbittorrent-clientblocker.nix {
    inherit localFlake withSystem;
  };
  snell-server = importApply ./snell-server.nix { inherit localFlake withSystem; };
  tcp-brutal = importApply ./tcp-brutal.nix { inherit localFlake withSystem; };
}
