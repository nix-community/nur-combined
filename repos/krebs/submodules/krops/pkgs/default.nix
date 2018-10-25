{ overlays ? [], ... }@args:

let
  nix-writers = builtins.fetchGit {
    url = https://cgit.krebsco.de/nix-writers/;
    rev = "c27a9416e8ee04d708b11b48f8cf1a055c0cc079";
  };
in

import <nixpkgs> (args // {
  overlays = overlays ++ [
    (import ./overlay.nix)
    (import "${nix-writers}/pkgs")
  ];
})
