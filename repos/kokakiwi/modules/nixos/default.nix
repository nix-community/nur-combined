{
  all-modules = [
    ./networking/netns.nix

    ./services/pueue.nix
    ./services/qbittorrent.nix
  ];

  networking = {
    netns = import ./networking/netns.nix;
  };
  services = {
    pueue = import ./services/pueue.nix;
    qbittorrent = import ./services/qbittorrent.nix;
  };
}
