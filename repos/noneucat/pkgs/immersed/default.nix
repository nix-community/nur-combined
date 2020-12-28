{ stdenv, wrapGAppsHook, autoPatchelfHook, fetchurl, ffmpeg-full, p7zip
, gtk3, gdk-pixbuf, glib, pango, cairo, fontconfig, libva
, xorg, zlib, glibc, libpulseaudio }:

stdenv.mkDerivation {
  pname = "Immersed";
  version = "4.0";

  src = fetchurl {
    url = "https://immersedvr.com/dl/Immersed-x86_64.AppImage";
    sha256 = "1n95pfx899lxdir293364sa2vh16n1xvxqb2dj960c47a4qqirlb";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    wrapGAppsHook 
    p7zip
  ];

  buildInputs = [
    libpulseaudio
    gtk3
    pango
    gdk-pixbuf
    glib
    fontconfig
    cairo
    zlib
    glibc
    libva.out
    libva

    xorg.libX11
    xorg.libXcomposite
    xorg.libXdamage
    xorg.libXext
    xorg.libXfixes
    xorg.libXinerama
    xorg.libXtst
    xorg.libXxf86vm
    xorg.libSM
  ];

  unpackPhase = ''
    7z x $src 
  '';

  dontBuild = true;

  installPhase = ''
    mkdir -p $out/bin
    mkdir -p $out/lib/va2

    install -Dm755 usr/bin/Immersed $out/bin/Immersed

    ln -s ${ffmpeg-full}/lib/libavcodec.so $out/lib/va2
    ln -s ${ffmpeg-full}/lib/libavdevice.so $out/lib/va2
    ln -s ${ffmpeg-full}/lib/libavfilter.so $out/lib/va2
    ln -s ${ffmpeg-full}/lib/libavformat.so $out/lib/va2
    ln -s ${ffmpeg-full}/lib/libavutil.so $out/lib/va2
    ln -s ${ffmpeg-full}/lib/libswresample.so $out/lib/va2
    ln -s ${ffmpeg-full}/lib/libswscale.so $out/lib/va2
  '';

  meta = {
    description = "Immersed VR agent for Linux";
    homepage = "https://immersedvr.com/";
    downloadPage = "https://immersedvr.com/dl/Immersed-x86_64.AppImage";
    license = stdenv.lib.licenses.unfree;
    maintainers = [ stdenv.lib.maintainers.noneucat ];
    platforms = [ "x86_64-linux" ];
  };
}
