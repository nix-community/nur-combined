{
  lib,
  fetchurl,
  ocamlPackages,
}:

ocamlPackages.buildDunePackage rec {
  pname = "datalog";
  version = "0.7";

  src = fetchurl {
    url = "https://github.com/c-cube/datalog/releases/download/v${version}/datalog-${version}.tbz";
    hash = "sha256-E8pSC9308MRNFGi8iTR75y7FQ75Y//KUaaDaJJVr5UE=";
  };

  minimalOCamlVersion = "4.08";

  meta = {
    description = "In-memory datalog implementation for OCaml";
    homepage = "https://github.com/c-cube/datalog";
    license = lib.licenses.bsd2;
    maintainers = [ ];
  };
}
