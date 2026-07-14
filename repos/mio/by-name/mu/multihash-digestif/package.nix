{
  lib,
  fetchurl,
  multihash,
  ocamlPackages,
}:

ocamlPackages.buildDunePackage rec {
  pname = "multihash-digestif";
  version = "0.1.0";

  src = fetchurl {
    url = "https://github.com/patricoferris/ocaml-multihash/releases/download/v${version}/multihash-${version}.tbz";
    hash = "sha256-y2iH+i4x3AbZWxXWeMqaD6JYvkwy0G253wt5gb24pfY=";
  };

  propagatedBuildInputs = with ocamlPackages; [
    digestif
    multihash
  ];

  meta = {
    description = "Self-describing hash functions using Digestif";
    homepage = "https://github.com/patricoferris/ocaml-multihash";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
