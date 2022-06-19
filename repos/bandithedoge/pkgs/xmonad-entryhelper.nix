{
  pkgs,
  sources,
}:
pkgs.haskellPackages.callCabal2nix "xmonad-entryhelper" sources.xmonad-entryhelper.src {}
