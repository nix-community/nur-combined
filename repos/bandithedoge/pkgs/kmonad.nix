{
  pkgs,
  sources,
}:
(pkgs.haskellPackages.callCabal2nix "kmonad" sources.kmonad.src {}).overrideAttrs (oldAttrs: {
  buildInputs = oldAttrs.buildInputs ++ [pkgs.git];
})
