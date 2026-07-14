{
  lib,
  fetchurl,
  ocamlPackages,
}:

ocamlPackages.buildDunePackage rec {
  pname = "multicodec";
  version = "0.1.0";

  src = fetchurl {
    url = "https://github.com/patricoferris/ocaml-multicodec/releases/download/v${version}/multicodec-${version}.tbz";
    hash = "sha256-Vq606i0qikc8TXWoPhGb8RUWNs0/Rp6inxeYEOQLIss=";
  };

  minimalOCamlVersion = "4.03";

  meta = {
    description = "Canonical codec of values and types used by various multiformats";
    homepage = "https://github.com/patricoferris/ocaml-multicodec";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
