{ lib
, stdenv
, fetchFromGitHub
, buildNpmPackage
}:

buildNpmPackage rec {
  pname = "lovelace-auto-entities";
  version = "1.16.1";

  src = fetchFromGitHub {
    owner = "thomasloven";
    repo = "lovelace-auto-entities";
    rev = "v${version}";
    hash = "sha256-yMqf4LA/fBTIrrYwacUTb2fL758ZB1k471vdsHAiOj8=";
  };
  
  npmDepsHash = "sha256-XLhTLK08zW1BFj/PI8/61FWzoyvWi5X5sEkGlF1IuZU=";

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
