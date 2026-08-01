{
  lib,
  stdenv,
  fetchFromGitHub,
  readline,
}:

stdenv.mkDerivation {
  pname = "zforth";
  version = "0-unstable-2025-08-15";

  src = fetchFromGitHub {
    owner = "zevv";
    repo = "zForth";
    rev = "41db72d165c1539d57f3f79970fc57ea881a79dc";
    hash = "sha256-orHD3dy0SVc+8FXgM28ft3v6xA+RbGKRSBWhKhqs2IM=";
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
