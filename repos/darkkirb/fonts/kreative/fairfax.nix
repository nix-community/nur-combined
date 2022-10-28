{
  stdenv,
  callPackage,
  lib,
}: let
  source = builtins.fromJSON (builtins.readFile ./source.json);
in
  stdenv.mkDerivation {
    name = "fairfax";
    version = source.date;
    src = callPackage ./source.nix {};
    preferLocalBuild = true;
    buildPhase = "true";
    installPhase = ''
      for variant in "" Bold Hax HaxBold HaxItalic Italic Pona SM SMBold SMItalic Serif SerifHax SerifSM; do
        install -m444 -Dt $out/share/truetype/Fairfax Fairfax/Fairfax$variant.ttf
      done
    '';
    meta = {
      description = "6x12 Bitmap Font supporting many Unicode Characters and Constructed Scripts";
      license = lib.licenses.ofl;
    };
  }
