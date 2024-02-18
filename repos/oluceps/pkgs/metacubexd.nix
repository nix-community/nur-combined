{ fetchurl, stdenvNoCC }:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "metacubexd";
  version = "1.129.0";
  src = fetchurl {
    url = "https://github.com/MetaCubeX/metacubexd/releases/download/v${finalAttrs.version}/compressed-dist.tgz";
    hash = "sha256-qfmmhtC+FY9VHkeYGJPr6NqbJByLBMEsm8y8ZQkBICE=";
  };
  sourceRoot = ".";
  installPhase = ''
    mkdir -p $out
    cp -r ./* $out
  '';
})
