{
  pkgs,
  sources,
}:
pkgs.haskellPackages.callCabal2nix "taffybar" sources.taffybar.src {inherit (pkgs) gtk3;}
