{ lib, fetchurl, fetchFromGitHub, makeDesktopItem, copyDesktopItems,
  cmake, ffmpeg, librsvg, mpv, nodejs, openssl, qt5, which }:

let
  version = "4.4.142";
  serverJS = fetchurl {
    url = "https://s3-eu-west-1.amazonaws.com/stremio-artifacts/four/v${version}/server.js";
    sha256 = "sha256:0av15k15lbl2m50f2kg42bmi8xc8as7h1yb33i806bhv47fq71v1";
  };
  stremioIcon = fetchurl {
    url = "https://www.stremio.com/website/stremio-logo-small.png";
    sha256 = "15zs8h7f8fsdkpxiqhx7wfw4aadw4a7y190v7kvay0yagsq239l6";
  };
in qt5.mkDerivation rec {
  pname = "stremio";
  inherit version;

  src = fetchFromGitHub {
    owner = "Stremio";
    repo = "stremio-shell";
    rev = "v${version}";
    sha256 = "sha256-OyuTFmEIC8PH4PDzTMn8ibLUAzJoPA/fTILee0xpgQI=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ which cmake copyDesktopItems ];
  buildInputs = [
    ffmpeg
    mpv
    nodejs
    openssl
    qt5.qtbase
    qt5.qtdeclarative
    qt5.qtquickcontrols
    qt5.qtquickcontrols2
    qt5.qttools
    qt5.qttranslations
    qt5.qtwebchannel
    qt5.qtwebengine
    librsvg
  ];

  desktopItems = makeDesktopItem {
    name = pname;
    exec = "stremio";
    icon = stremioIcon;
    comment = meta.description;
    desktopName = "Stremio";
    genericName = "Movies and TV Series";
  };

  dontWrapQtApps = true;
  
  preFixup = ''
    mkdir -p $out/bin
    mkdir -p $out/opt/stremio
    cp stremio $out/opt/stremio/
    cp ${serverJS} $out/opt/stremio/server.js
    ln -s "$(which node)" "$out/opt/stremio/node"
    ln -s "$out/opt/stremio/stremio" "$out/bin/stremio"
  '';

  postFixup = ''
    wrapQtApp "$out/opt/stremio/stremio" --prefix PATH : "$out/opt/stremio"
  '';

  meta = with lib; {
    description = "Modern media center that gives you the freedom to watch everything you want";
    homepage = "https://github.com/Stremio/stremio-shell";
    license = licenses.gpl3;
    platforms = [ "x86_64-linux" ];
  };
}
