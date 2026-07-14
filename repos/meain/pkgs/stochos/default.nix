{ lib
, stdenv
, fetchurl
}:

stdenv.mkDerivation rec {
  pname = "stochos";
  version = "1.0.0";

  src = fetchurl {
    url = "https://github.com/museslabs/stochos/releases/download/v${version}/stochos-darwin-aarch64.tar.gz";
    hash = "sha256-iy330fBOmct7/skM8UEKw8KxIttkfI576OcZvMT/Jyk=";
  };

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    install -m755 stochos $out/bin/stochos
    runHook postInstall
  '';

  meta = with lib; {
    description = "Keyboard-driven mouse control overlay for Wayland, X11, and macOS";
    homepage = "https://github.com/museslabs/stochos";
    license = licenses.gpl3Only;
    maintainers = [ ];
    platforms = [ "aarch64-darwin" ];
    broken = !stdenv.hostPlatform.isAarch64 || !stdenv.hostPlatform.isDarwin;
    mainProgram = "stochos";
  };
}
