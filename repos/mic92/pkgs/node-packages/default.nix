{ pkgs, system, nodejs-14_x, makeWrapper }:
let
  nodePackages = import ./composition.nix {
    inherit pkgs system;
    nodejs = nodejs-14_x;
  };
in
(
  nodePackages
  // {
    reveal-md = nodePackages.reveal-md.override {
      PUPPETEER_SKIP_CHROMIUM_DOWNLOAD = true;
    };
    backport = nodePackages.backport.override (
      oldAttrs: {
        dontNpmInstall = true;
        buildInputs = [ makeWrapper ];
        postInstall = ''
          makeWrapper ${nodejs-14_x}/bin/node $out/bin/backport \
            --add-flags "$out/lib/node_modules/backport/dist/cli/index.js"
        '';
      }
    );
  }
)
