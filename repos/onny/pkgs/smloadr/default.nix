{ pkgs, nodejs, stdenv, lib, ... }:

let

  packageName = with lib; concatStrings (map (entry: (concatStrings (mapAttrsToList (key: value: "${key}-${value}") entry))) (importJSON ./package.json));

  nodePackages = import ./node-composition.nix {
    inherit pkgs nodejs;
    inherit (stdenv.hostPlatform) system;
  };

in nodePackages."${packageName}".override {
  nativeBuildInputs = [ pkgs.makeWrapper ];

  postInstall = ''
    rm $out/bin/SMLoadr

    # main binary wrapper
    makeWrapper '${nodejs}/bin/node' "$out/bin/SMLoadr" \
      --add-flags "$out/lib/node_modules/SMLoadr/SMLoadr.js"
  '';

  # other metadata generated and inherited from ./node-package.nix
  #meta.maintainers = with stdenv.lib.maintainers; [ onny ];
}
