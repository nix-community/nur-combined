{
  lib,
  fetchurl,
  ocamlPackages,
}:

ocamlPackages.buildDunePackage rec {
  pname = "ocaml-index";
  version = "5.6-504";

  src = fetchurl {
    url = "https://github.com/ocaml/merlin/releases/download/v${version}/merlin-${version}.tbz";
    hash = "sha256-gtZIpBgNbVqjoIMhjii/GX9OnxR4hN6TArtoEa2Yt38=";
  };

  minimalOCamlVersion = "5.4";

  propagatedBuildInputs = with ocamlPackages; [
    merlin-lib
  ];

  meta = {
    description = "Tool that indexes value usages from cmt files";
    homepage = "https://github.com/ocaml/merlin/ocaml-index";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "ocaml-index";
  };
}
