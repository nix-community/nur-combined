{ gcc9Stdenv
, fetchFromGitHub
, makeDesktopItem
, cmake
, pkg-config
, doxygen
, wrapQtAppsHook
, pcre
, poco
, qtbase
, qtsvg
, libsForQt5
, nlohmann_json
, soapysdr-with-plugins
, portaudio
, alsaLib
, muparserx
, python3
}:

# Fails to build with GCC 10
gcc9Stdenv.mkDerivation rec {
  pname = "pothos";
  version = "0.7.0";

  src = fetchFromGitHub {
    owner = "pothosware";
    repo = "PothosCore";
    rev = "pothos-${version}";
    sha256 = "1mcg64bgxpd1765xszqwjsgf27bxj5s6jzx6gyjcqs3d3qk6isqb";
    fetchSubmodules = true;
  };

  patches = [ ./spuce.patch ];

  nativeBuildInputs = [ cmake pkg-config doxygen wrapQtAppsHook ];

  buildInputs = [
    pcre poco qtbase qtsvg libsForQt5.qwt nlohmann_json
    soapysdr-with-plugins portaudio alsaLib muparserx python3
  ];

  postInstall = ''
    install -Dm644 $out/share/Pothos/Desktop/pothos-flow.desktop $out/share/applications/pothos-flow.desktop
    install -Dm644 $out/share/Pothos/Desktop/pothos-flow-16.png $out/share/icons/hicolor/16x16/apps/pothos-flow.png
    install -Dm644 $out/share/Pothos/Desktop/pothos-flow-22.png $out/share/icons/hicolor/22x22/apps/pothos-flow.png
    install -Dm644 $out/share/Pothos/Desktop/pothos-flow-32.png $out/share/icons/hicolor/32x32/apps/pothos-flow.png
    install -Dm644 $out/share/Pothos/Desktop/pothos-flow-48.png $out/share/icons/hicolor/48x48/apps/pothos-flow.png
    install -Dm644 $out/share/Pothos/Desktop/pothos-flow-64.png $out/share/icons/hicolor/64x64/apps/pothos-flow.png
    install -Dm644 $out/share/Pothos/Desktop/pothos-flow-128.png $out/share/icons/hicolor/128x128/apps/pothos-flow.png
    install -Dm644 $out/share/Pothos/Desktop/pothos-flow.xml $out/share/mime/application/pothos-flow.xml
    rm -r $out/share/Pothos/Desktop
  '';

  preFixup = ''
    wrapQtApp $out/bin/PothosFlow
  '';

  meta = with gcc9Stdenv.lib; {
    description = "The Pothos data-flow framework";
    homepage = "https://github.com/pothosware/PothosCore/wiki";
    license = licenses.boost;
    platforms = platforms.linux;
  };
}
