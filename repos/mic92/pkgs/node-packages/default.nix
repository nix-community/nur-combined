{ pkgs, system, nodejs, makeWrapper }:

let
  nodePackages = import ./composition.nix {
    inherit pkgs system nodejs;
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
          makeWrapper ${nodejs}/bin/node $out/bin/backport \
            --add-flags "$out/lib/node_modules/backport/dist/cli/index.js"
        '';
      }
    );
  }
)
