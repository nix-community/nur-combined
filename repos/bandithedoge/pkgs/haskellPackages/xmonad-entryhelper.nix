{
  pkgs,
  sources,
  haskellNix,
}:
haskellNix.project {
  inherit (sources.xmonad-entryhelper) src;
}
