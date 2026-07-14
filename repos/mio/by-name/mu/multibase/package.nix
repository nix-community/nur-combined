{
  lib,
  fetchurl,
  ocamlPackages,
}:

ocamlPackages.buildDunePackage rec {
  pname = "multibase";
  version = "0.1.0";

  src = fetchurl {
    url = "https://github.com/patricoferris/ocaml-multibase/releases/download/v${version}/multibase-${version}.tbz";
    hash = "sha256-tGUJ3ZL+8V0reKTIMfp8LK7vF+RU9iFxGicA3YKhWpU=";
  };

  minimalOCamlVersion = "4.08";

  propagatedBuildInputs = with ocamlPackages; [
    base64
    optint
  ];

  meta = {
    description = "Self-describing base encodings";
    homepage = "https://github.com/patricoferris/ocaml-multibase";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
