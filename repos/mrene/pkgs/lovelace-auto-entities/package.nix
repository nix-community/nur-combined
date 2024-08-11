{ lib
, stdenv
, fetchFromGitHub
, buildNpmPackage
}:

buildNpmPackage rec {
  pname = "lovelace-auto-entities";
  version = "1.13.0";

  src = fetchFromGitHub {
    owner = "thomasloven";
    repo = "lovelace-auto-entities";
    rev = "v${version}";
    hash = "sha256-ls8Jqt5SdiY5ROhtaSS4ZvoY+nHv6UB1RYApOJzC1VQ=";
  };
  
  npmDepsHash = "sha256-9z4YzLNxNh7I4yFxuPT3/erZO4itAiqyxL1a0pUTFRs=";

  installPhase = ''
    runHook preInstall

    mkdir $out
    cp ./auto-entities.js $out/

    runHook postInstall
  '';


  passthru = {
    entrypoint = "auto-entities.js";
  };

  makeCacheWritable = true;

  # doDist = false;
  meta = with lib; {
    description = "Automatically populate the entities-list of lovelace cards";
    homepage = "https://github.com/thomasloven/lovelace-auto-entities";
    license = licenses.mit;
    maintainers = with maintainers; [ mrene ];
    mainProgram = "lovelace-auto-entities";
    platforms = platforms.linux;
  };
}
