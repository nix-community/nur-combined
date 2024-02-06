{ pkgs, ... }: {
  home.packages = with pkgs; [ cabal-install ghc haskell-language-server ];
}
