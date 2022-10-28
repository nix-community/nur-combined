{
  stdenv,
  callPackage,
  lib,
}: let
  source = builtins.fromJSON (builtins.readFile ./source.json);
in
  stdenv.mkDerivation {
    name = "kreative-square";
    version = source.date;
    src = callPackage ./source.nix {};
    preferLocalBuild = true;
    buildPhase = "true";
    installPhase = ''
      for variant in "" SM; do
        install -m444 -Dt $out/share/truetype/KreativeSquare KreativeSquare/KreativeSquare$variant.ttf
      done
    '';
    meta = {
      description = "Fullwidth scalable monospace font with many Box Drawing characters";
      license = lib.licenses.ofl;
    };
  }
