{ lib, callPackage }:
let
  version = "1.0";
in
{
  rus-fin-pogovorki = callPackage ./base.nix {
    pname = "rus-fin-pogovorki";
    inherit version;
    filename = "rus-fin_Pogovorki_${lib.replaceStrings [ "." ] [ "_" ] version}GD.zip";
    description = "Русские поговорки и их финские аналоги (Rus-Fin)";
    sha256 = "0zvzkdl2wb8dvfbnyv3azzxygqhzcpcj93l422kb2snssfm2451v";
  };

  fin-fin-synonyms = callPackage ./base.nix {
    pname = "fin-fin-synonyms";
    inherit version;
    filename = "fin-fin_Synonyms_${lib.replaceStrings [ "." ] [ "_" ] version}GD.zip";
    description = "Finnish Synonyms (Fin-Fin)";
    sha256 = "1757v6x89jghl9hz57hq9dm8lgx6d48rnrpfc2zpijxv8xk8g5w7";
  };
}
