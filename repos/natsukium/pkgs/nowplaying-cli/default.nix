{
  lib,
  stdenv,
  fetchFromGitHub,
  Cocoa,
}:
stdenv.mkDerivation rec {
  pname = "nowplaying-cli";
  version = "1.2.1";

  src = fetchFromGitHub {
    owner = "kirtan-shah";
    repo = "nowplaying-cli";
    rev = "v${version}";
    hash = "sha256-FkyrtgsGzpK2rLNr+oxfPUbX43TVXYeiBg7CN1JUg8Y=";
  };

  buildInputs = [Cocoa];

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
