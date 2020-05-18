{ stdenv, fetchFromGitHub, cmake, python3, pkgconfig, gtk3
, glew, webkitgtk, icu, boost, curl, alsaLib, makeWrapper
, gnome3, makeDesktopItem }:

let
  desktopItem = makeDesktopItem rec {
    name = "KnobKraft-orm";
    exec = "KnobKraftOrm";
    desktopName = name;
    genericName = "KnobKraft Orm";
    categories = "Audio;AudioVideo;";
  };
in stdenv.mkDerivation rec {
  pname = "KnobKraft-orm";
  version = "1.4.0";

  src = fetchFromGitHub {
    owner = "christofmuc";
    repo = "KnobKraft-orm";
    rev = version;
    sha256 = "0xbxamscfraw9r41g02p2vjvzba6s46l88q31h87hgzldfsd3kzb";
    fetchSubmodules = true;
  };

  buildInputs = [
    gtk3 glew webkitgtk icu boost curl alsaLib
  ];
  nativeBuildInputs = [
    cmake python3 pkgconfig makeWrapper
  ];

  preConfigure = ''
    # adaptions are installed under $out/opt/KnobKraft-orm-adaptions
    export HOME=$out/opt
    substituteInPlace adaptions/GenericAdaption.cpp \
      --replace 'File::getSpecialLocation(File::userDocumentsDirectory).getFullPathName() + "/KnobKraft-Orm-adaptions"' \
        \"$out/opt/KnobKraft-orm-adaptions\"
  '';

  installPhase = ''
    install -Dm755 ./The-Orm/KnobKraftOrm $out/bin/KnobKraftOrm
    # make file dialogs work under JUCE
    wrapProgram $out/bin/KnobKraftOrm \
      --prefix PATH ":" ${gnome3.zenity}/bin

    ln -s ${desktopItem}/share $out
  '';

  meta = with stdenv.lib; {
    description = "Free modern cross-platform MIDI Sysex Librarian";
    homepage = src.meta.homepage;
    license = licenses.agpl3;
    platforms = platforms.linux;
    maintainers = with maintainers; [ gnidorah ];
  };
}
