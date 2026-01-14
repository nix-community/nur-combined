{
  nixpkgs.overlays = [
    (import ../overlays).default
  ];
}
