{ emacsWithPackages, notmuch, ... }:

emacsWithPackages
  (epkgs: (with epkgs.melpaStablePackages; [
    magit
    evil
    linum-relative
    auto-complete
    fiplr
    rainbow-delimiters
    free-keys
    base16-theme

    nix-mode
    rust-mode
    markdown-mode
    haskell-mode
    lua-mode
  ]) ++ (with epkgs.elpaPackages; [
  ]))
