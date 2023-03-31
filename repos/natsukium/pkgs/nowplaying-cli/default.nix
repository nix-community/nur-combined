{
  lib,
  stdenv,
  fetchFromGitHub,
  Cocoa,
}:
stdenv.mkDerivation rec {
  pname = "nowplaying-cli";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "kirtan-shah";
    repo = "nowplaying-cli";
    rev = "v${version}";
    hash = "sha256-IBAWeBtFAKjvmOkgyHnx4m66UO0Eu4rywPxEFgxM6nQ=";
  };

  buildInputs = [Cocoa];

  buildPhase = ''
    runHook preBuild

    ${stdenv.cc}/bin/cc nowplaying.mm -framework Cocoa -o nowplaying-cli -O3

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    install -Dm755 nowplaying-cli $out/bin/nowplaying-cli

    runHook postInstall
  '';

  meta = with lib; {
    description = "A commandline utility for currently playing media for macOS";
    homepage = "https://github.com/kirtan-shah/nowplaying-cli";
    license = licenses.gpl3;
    platforms = platforms.darwin;
  };
}
