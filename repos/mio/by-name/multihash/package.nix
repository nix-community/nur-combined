{
  lib,
  fetchurl,
  multicodec,
  ocamlPackages,
}:

ocamlPackages.buildDunePackage rec {
  pname = "multihash";
  version = "0.1.0";

  src = fetchurl {
    url = "https://github.com/patricoferris/ocaml-multihash/releases/download/v${version}/multihash-${version}.tbz";
    hash = "sha256-y2iH+i4x3AbZWxXWeMqaD6JYvkwy0G253wt5gb24pfY=";
  };

  minimalOCamlVersion = "4.08";

  propagatedBuildInputs = with ocamlPackages; [
    cstruct
    multicodec
  ];

  meta = {
    description = "Self-describing hash functions";
    homepage = "https://github.com/patricoferris/ocaml-multihash";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
