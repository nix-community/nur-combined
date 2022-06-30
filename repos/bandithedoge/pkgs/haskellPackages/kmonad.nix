{
  pkgs,
  sources,
  haskellNix,
}:
haskellNix.project {
  inherit (sources.kmonad) src;
}
