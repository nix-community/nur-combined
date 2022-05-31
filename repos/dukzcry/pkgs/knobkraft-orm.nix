{ stdenv, lib, fetchFromGitHub, cmake, python3, pkgconfig, gtk3
, glew, webkitgtk, icu, boost, curl, alsaLib, makeWrapper
, gnome3, makeDesktopItem, gcc-unwrapped
, debug ? false }:

let
  desktopItem = makeDesktopItem rec {
    name = "KnobKraft-orm";
    exec = "KnobKraftOrm";
    icon = "icon_orm";
    desktopName = name;
    genericName = "KnobKraft Orm";
    categories = [ "Audio" "AudioVideo" ];
  };
  inherit (lib) optional optionalString;
in stdenv.mkDerivation rec {
  pname = "KnobKraft-orm";
  version = "1.10.1";

  src = fetchFromGitHub {
    owner = "christofmuc";
    repo = "KnobKraft-orm";
    rev = version;
    sha256 = "1ykqywrwpiavh1syavs2bv959ifjqlqgn8lq1w6msjy10pf6g106";
    fetchSubmodules = true;
  };

  dontStrip = debug;
  makeFlags = optional (debug) [ "CFLAGS+=-Og" "CFLAGS+=-ggdb" ];

  cmakeFlags = [
    "-DCMAKE_AR=${gcc-unwrapped}/bin/gcc-ar"
    "-DCMAKE_RANLIB=${gcc-unwrapped}/bin/gcc-ranlib"
  ] ++ optional debug [ "-DCMAKE_BUILD_TYPE=Debug" ];

  buildInputs = [
    gtk3 glew webkitgtk icu boost curl alsaLib
  ];
  nativeBuildInputs = [
    cmake python3 pkgconfig makeWrapper
  ];

  installPhase = ''
    install -Dm755 ./The-Orm/KnobKraftOrm $out/bin/KnobKraftOrm
    # make file dialogs work under JUCE
    ${optionalString (!debug) ''
      wrapProgram $out/bin/KnobKraftOrm --prefix PATH ":" ${gnome3.zenity}/bin
    ''}

    mkdir -p $out/share/applications $out/share/icons/hicolor/256x256/apps
    ln -s ${desktopItem}/share/applications/* $out/share/applications
    cp $src/The-Orm/resources/icon_orm.png $out/share/icons/hicolor/256x256/apps
  '';

  meta = with lib; {
    description = "Free modern cross-platform MIDI Sysex Librarian";
    homepage = src.meta.homepage;
    license = licenses.agpl3;
    platforms = platforms.linux;
    maintainers = with maintainers; [ ];
  };
}
