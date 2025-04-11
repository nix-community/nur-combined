{
  lib,
  stdenv,
  fetchFromGitHub,
  readline,
}:

stdenv.mkDerivation {
  pname = "zforth";
  version = "0-unstable-2025-03-30";

  src = fetchFromGitHub {
    owner = "zevv";
    repo = "zForth";
    rev = "4f447527f732dc46f389a47b873077f287e0073e";
    hash = "sha256-PMC0szoJV57w3IVUKoAth9g9F1g7aAAs33ppuVzRQ2o=";
  };

  buildInputs = [ readline ];

  installPhase = ''
    runHook preInstall

    install -Dm755 -t $out/bin src/linux/zforth
    install -Dm644 -t $out/share/zforth/ forth/*

    runHook postInstall
  '';

  meta = {
    description = "tiny, embeddable, flexible, compact Forth scripting language for embedded systems";
    homepage = "https://github.com/zevv/zForth";
    license = with lib.licenses; [ mit ];
    mainProgram = "zforth";
  };
}
