{
  buildNpmPackage,
  nodejs,
  bash,
  fetchFromGitHub,
}:
buildNpmPackage rec {
  pname = "vscode-markdown-languageserver";
  version = "0.5.0-alpha.12";
  src = fetchFromGitHub {
    owner = "microsoft";
    repo = "vscode-markdown-languageserver";
    tag = "v${version}";
    sha256 = "sha256-3EIk+IXfV8GiLaTUpAataKtycQzsjAY4wP4vhd/4qcw=";
  };
  npmDepsHash = "sha256-X+i/s9X6CDAvNYXnCfb+BDYOYHDni+3pvCodyEEJmi0=";
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
