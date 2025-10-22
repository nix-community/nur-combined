{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
}:

stdenvNoCC.mkDerivation {
  pname = "ttf-wps-fonts";
  version = "unstable-2024-10-29";

  # inherit pname version;
  src = fetchFromGitHub {
    name = "ttf-wps-fonts";
    owner = "dv-anomaly";
    repo = "ttf-wps-fonts";
    rev = "8c980c24289cb08e03f72915970ce1bd6767e45a";
    sha256 = "sha256-x+grMnpEGLkrGVud0XXE8Wh6KT5DoqE6OHR+TS6TagI=";
  };

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/fonts/truetype
    install -D *.{ttf,TTF} $out/share/fonts/truetype

    runHook postInstall
  '';

  meta = {
    homepage = "https://github.com/dv-anomaly/ttf-wps-fonts";
    description = "WPS Office TrueType fonts";
    license = lib.licenses.unfree;
    platforms = lib.platforms.all;
  };
}
