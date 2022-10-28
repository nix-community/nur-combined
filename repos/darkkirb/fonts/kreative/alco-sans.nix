{
  stdenv,
  callPackage,
  lib,
}: let
  source = builtins.fromJSON (builtins.readFile ./source.json);
in
  stdenv.mkDerivation {
    name = "alco-sans";
    version = source.date;
    src = callPackage ./source.nix {};
    preferLocalBuild = true;
    buildPhase = "true";
    installPhase = ''
      install -m444 -Dt $out/share/truetype/AlcoSans AlcoSans/AlcoSans.ttf
    '';
    meta = {
      description = "Font by Kreative Software";
      license = lib.licenses.ofl;
    };
  }
