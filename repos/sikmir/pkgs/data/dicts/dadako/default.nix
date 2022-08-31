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
    hash = "sha256-9tOdf+5INmhbsek9HT5reBTrflhOJ614tRfMOHfMdFA=";
  };

  fin-fin-synonyms = callPackage ./base.nix {
    pname = "fin-fin-synonyms";
    inherit version;
    filename = "fin-fin_Synonyms_${lib.replaceStrings [ "." ] [ "_" ] version}GD.zip";
    description = "Finnish Synonyms (Fin-Fin)";
    hash = "sha256-Yc+L9v6gNrGaD8FJ36CtkPovWEekwuaLYsG7E/WH5Dk=";
  };
}
