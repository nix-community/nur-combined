{ stdenv, fetchFromGitHub
, pkgconfig, makeWrapper
, alsaLib, freetype, xorg, curl, libGL, libjack2, gnome3
}:

stdenv.mkDerivation rec {
  name = "helio-workstation-2.0.9a03740";
  version = "9a03740fefb9a2efb33c1ad797170bdc4e9be9f4";

  src = fetchFromGitHub {
    owner = "helio-fm";
    repo = "helio-workstation";
    rev = "${version}";
    fetchSubmodules = true;
    sha256 = "0wdkqij438rqxwg87cpygb4nwjm4s4rmmkm07chxs7hnddad44a8";
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
