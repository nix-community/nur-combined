{ stdenv, fetchFromGitHub
, pkgconfig, makeWrapper
, alsaLib, freetype, xorg, curl, libGL, libjack2, gnome3
}:

stdenv.mkDerivation rec {
  name = "helio-workstation-2.1";
  version = "2.1";

  src = fetchFromGitHub {
    owner = "helio-fm";
    repo = "helio-workstation";
    rev = "${version}";
    fetchSubmodules = true;
    sha256 = "0m060znilm1vw8wn0jgs7qnmap13jgzk16qmy0ww92ldf56bkgxk";
  };

  buildInputs = [
    alsaLib freetype xorg.libX11 xorg.libXext xorg.libXinerama xorg.libXrandr
    xorg.libXcursor xorg.libXcomposite curl libGL libjack2 gnome3.zenity
  ];

  nativeBuildInputs = [ pkgconfig makeWrapper ];

  preBuild = "cd Projects/LinuxMakefile";
  buildFlags = [ "CONFIG=Release64" ];

  installPhase = ''
    mkdir -p $out/bin
    install -m +x build/Helio $out/bin
    wrapProgram $out/bin/Helio --prefix PATH ":" ${gnome3.zenity}/bin
  '';

  meta = with stdenv.lib; {
    description = "One music sequencer for all major platforms, both desktop and mobile";
    homepage = https://helio.fm/;
    license = licenses.gpl3;
    maintainers = [ ];
    platforms = platforms.linux;
  };
}
