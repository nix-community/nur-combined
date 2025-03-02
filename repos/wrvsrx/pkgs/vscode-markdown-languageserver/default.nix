{
  buildNpmPackage,
  nodejs,
  bash,
  fetchFromGitHub,
}:
buildNpmPackage rec {
  pname = "vscode-markdown-languageserver";
  version = "0.5.0-alpha.7";
  src = fetchFromGitHub {
    owner = "microsoft";
    repo = "vscode-markdown-languageserver";
    tag = "v${version}";
    sha256 = "sha256-qBXpBGdh8ehk/94nbE5Y9ispEz/d5DMXl1OVEH8AmCU=";
  };
  npmDepsHash = "sha256-mkM30n3ieOI/E4lRGQxCao5fPf13RnXJz5QzmEc4KPE=";
  buildPhase = "npm run dist";
  installPhase = ''
    mkdir -p $out/bin
    mv dist $out/dist
    cat > $out/bin/$pname <<- EOF
    #!${bash}/bin/bash

    ${nodejs}/bin/node $out/dist/node/workerMain.js \$@
    EOF
    chmod +x $out/bin/$pname
  '';
}
