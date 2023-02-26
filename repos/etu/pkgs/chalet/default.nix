{
  lib,
  stdenv,
  pkgs,
  ...
}: let
  # Import package
  chaletPkg = (pkgs.callPackage ./chalet {}).package;
in
  stdenv.mkDerivation {
    pname = "chalet";

    # Extract version from json file
    version = builtins.replaceStrings ["^"] [""] (lib.importJSON ./chalet/package.json).dependencies.chalet;

    src = ./.;

    installPhase = ''
      mkdir -p $out/bin

      ln -s ${chaletPkg}/lib/node_modules/init-chalet/node_modules/chalet/lib/cli/bin.js $out/bin/chalet
    '';

    passthru.updateScript = ./chalet/update.sh;

    meta = with lib; {
      description = "Start apps from your browser";
      homepage = "https://github.com/jeansaad/chalet";
      maintainers = [maintainers.etu];
      platforms = platforms.all;
    };
  }
