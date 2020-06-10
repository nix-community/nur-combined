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
  version = "1.6.0";

  src = fetchFromGitHub {
    owner = "christofmuc";
    repo = "KnobKraft-orm";
    rev = version;
    sha256 = "05lh33mpqnrzqsmr7xmm8fz3kfvchv7927asms18z9si03f6681k";
    fetchSubmodules = true;
  };

  buildInputs = [
    gtk3 glew webkitgtk icu boost curl alsaLib
  ];
  nativeBuildInputs = [
    cmake python3 pkgconfig makeWrapper
  ];

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
