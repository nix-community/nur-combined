{
  lib,
  fetchurl,
  stdenv,
  undmg,
}:
stdenv.mkDerivation rec {
  pname = "qutebrowser";
  version = "3.1.0";

  src = fetchurl {
    url = "https://github.com/qutebrowser/qutebrowser/releases/download/v${version}/qutebrowser-${version}.dmg";
    sha256 = "sha256-AvuuwUnxMcr2ekZ/O1FL/4IizV1aTMhXNrbf1SwNY7U=";
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
