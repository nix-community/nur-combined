{ pkgs, system, nodejs_latest, makeWrapper }:
let
  nodePackages = import ./composition.nix {
    inherit pkgs system;
    nodejs = nodejs_latest;
  };
in
(
  nodePackages
  // {
    backport = nodePackages.backport.override (
      oldAttrs: {
        dontNpmInstall = true;
        buildInputs = [ makeWrapper ];
        postInstall = ''
          makeWrapper ${nodejs_latest}/bin/node $out/bin/backport \
            --add-flags "$out/lib/node_modules/backport/dist/cli/index.js"
        '';
      }
    );
  }
)
