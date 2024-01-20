{
  source,
  lib,
  stdenv,
  Cocoa,
}:
stdenv.mkDerivation {
  inherit (source) pname version src;

  buildInputs = [ Cocoa ];

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
