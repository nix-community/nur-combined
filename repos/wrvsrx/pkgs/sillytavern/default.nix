{
  buildNpmPackage,
  nodejs,
  bash,
  fetchFromGitHub,
}:
buildNpmPackage rec {
  pname = "sillytavern";
  version = "1.13.0";
  src = fetchFromGitHub {
    owner = "SillyTavern";
    repo = "SillyTavern";
    tag = version;
    sha256 = "sha256-HUlypAPadlad12J60Xfa30qE18II6MceVYkMqANWlyI=";
  };
  npmDepsHash = "sha256-IZMwDgazY+6oyuOlE7zdWcDn5D2/8v2mHX9yDBwK+4I=";
  buildPhase = "true";
  installPhase = ''
    mkdir -p $out/{bin,lib}
    mv * $out/lib
    rm $out/lib/node_modules/.package-lock.json
    cat > $out/bin/sillytavern <<- EOF
    #!${bash}/bin/bash

    ${nodejs}/bin/node $out/lib/server.js \$@
    EOF
    chmod +x $out/bin/sillytavern
  '';
}
