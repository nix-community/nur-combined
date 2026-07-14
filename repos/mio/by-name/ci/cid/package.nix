{
  lib,
  fetchurl,
  multibase,
  multicodec,
  multihash-digestif,
  ocamlPackages,
}:

ocamlPackages.buildDunePackage rec {
  pname = "cid";
  version = "0.1.0";

  src = fetchurl {
    url = "https://github.com/patricoferris/ocaml-cid/releases/download/v${version}/cid-${version}.tbz";
    hash = "sha256-VB9Tt83GK5hg2NxaaFZ1naNDlacbpM8tvareUi/mW/M=";
  };

  propagatedBuildInputs = [
    multibase
    multicodec
    multihash-digestif
  ];

  meta = {
    description = "Content-addressed identifiers";
    homepage = "https://github.com/patricoferris/ocaml-cid";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
