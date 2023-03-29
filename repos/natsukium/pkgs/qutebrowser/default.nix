{
  lib,
  fetchurl,
  stdenv,
  undmg,
}:
stdenv.mkDerivation rec {
  pname = "qutebrowser";
  version = "2.5.3";

  src = fetchurl {
    url = "https://github.com/qutebrowser/qutebrowser/releases/download/v${version}/qutebrowser-${version}.dmg";
    sha256 = "sha256-T3DMZhIuXxI1tDCEi7knu6lscGCVSjU1UW76SaKd1N4=";
  };

  nativeBuildInputs = [undmg];

  sourceRoot = "qutebrowser.app";

  installPhase = ''
    mkdir -p "$out/Applications/qutebrowser.app"
    cp -R . "$out/Applications/qutebrowser.app"
  '';

  meta = with lib; {
    description = "Keyboard-focused browser with a minimal GUI";
    homepage = "https://github.com/qutebrowser/qutebrowser";
    license = licenses.gpl3;
    platforms = platforms.darwin;
  };
}
