{ mkDerivation, stdenv, lib, pkg-config, fetchFromGitHub, qtbase, qtsvg, qtmultimedia, qmake, boost, openssl, wrapQtAppsHook }:

mkDerivation rec {
  pname = "chatterino7";
  version = "7.3.5";
  src = fetchFromGitHub {
    owner = "SevenTV";
    repo = pname;
    rev = "v${version}";
    sha256 = "lFzwKaq44vvkbVNHIe0Tu9ZFXUUDlWVlNXI40kb1GEM=";
    fetchSubmodules = true;
  };
  nativeBuildInputs = [ qmake pkg-config wrapQtAppsHook ];
  buildInputs = [ qtbase qtsvg qtmultimedia boost openssl ];
  postInstall = lib.optionalString stdenv.isDarwin ''
    mkdir -p "$out/Applications"
    mv bin/chatterino.app "$out/Applications/"
  '' + ''
    mkdir -p $out/share/icons/hicolor/256x256/apps
    cp $src/resources/icon.png $out/share/icons/hicolor/256x256/apps/chatterino.png
  '';
  meta = with lib; {
    description = "A chat client for Twitch chat";
    longDescription = ''
      Chatterino is a chat client for Twitch chat. It aims to be an
      improved/extended version of the Twitch web chat. Chatterino 7
      is the 7tv compatible fork of chatterino.
    '';
    homepage = "https://7tv.app/";
    license = licenses.mit;
    platforms = platforms.unix;
  };
}
