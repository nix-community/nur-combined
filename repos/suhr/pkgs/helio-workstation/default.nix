{ stdenv, fetchFromGitHub
, pkgconfig, makeWrapper
, alsaLib, freetype, xorg, curl, libGL, libjack2, gnome3
}:

stdenv.mkDerivation rec {
  name = "helio-workstation-2.0.716a4a1";
  version = "716a4a14f03665f88634b4d0c0d180071143e0be";

  src = fetchFromGitHub {
    owner = "helio-fm";
    repo = "helio-workstation";
    rev = "${version}";
    fetchSubmodules = true;
    sha256 = "1hssyzg5h5g56zad65llzca7dq8q11hpg468q7qgllvcf91lcmpn";
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
