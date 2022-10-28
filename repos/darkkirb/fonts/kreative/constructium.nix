{
  stdenv,
  callPackage,
  lib,
}: let
  source = builtins.fromJSON (builtins.readFile ./source.json);
in
  stdenv.mkDerivation {
    name = "constructium";
    version = source.date;
    src = callPackage ./source.nix {};
    preferLocalBuild = true;
    buildPhase = "true";
    installPhase = ''
      install -m444 -Dt $out/share/truetype/Constructium Constructium/Constructium.ttf
    '';
    meta = {
      description = "Fork of SIL Gentium with glyph for Constructed Languages";
      license = lib.licenses.ofl;
    };
  }
