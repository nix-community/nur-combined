{ pkgs, system, nodejs-18_x, makeWrapper }:
let
  nodePackages = import ./composition.nix {
    inherit pkgs system;
    nodejs = nodejs-18_x;
  };
in
(
  nodePackages
  // {
    reveal-md = nodePackages.reveal-md.override {
      PUPPETEER_SKIP_CHROMIUM_DOWNLOAD = true;
    };
  }
)
