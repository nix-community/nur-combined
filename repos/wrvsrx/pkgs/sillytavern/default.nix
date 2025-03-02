{
  buildNpmPackage,
  nodejs,
  bash,
  fetchFromGitHub,
}:
buildNpmPackage rec {
  pname = "sillytavern";
  version = "1.12.12";
  src = fetchFromGitHub {
    owner = "SillyTavern";
    repo = "SillyTavern";
    tag = version;
    sha256 = "sha256-uy7NxI8SkGZvSle2thjz3W2df7OxdlgKvHMFXlV+bI0=";
  };
  npmDepsHash = "sha256-fUJWBUxScllssxjhrJmql5ZiO/13K4Cz24moHgyq5NU=";
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
