{ stdenv, lib, fetchFromGitHub, makeDesktopItem, autoconf, autoconf-archive, automake, pkgconfig, alsaLib, SDL2, SDL2_net, libGL, libGLU, libogg, opusfile, graphicsmagick }:

stdenv.mkDerivation rec {
  name = "dosbox-staging";
  version = "1f1e832a6c18a282c41aa91f12aee858e1ddb8f4";

  src = fetchFromGitHub {
    owner = "dreamer";
    repo = name;
    rev = version;
    sha256 = "1s8bip3ks7v1xl97dgzr46lzwsgsxxm1imx6si0zs5f5a0qjnphr";
  };

  dontGzipMan = true;
  enableParallelBuilding = true;
  hardeningDisable = [ "format" ];

  nativeBuildInputs = [ pkgconfig graphicsmagick ];
  buildInputs = [ autoconf autoconf-archive automake SDL2 libGL libGLU libogg opusfile
  # Optional
  alsaLib # For ALSA audio support under Linux.
  SDL2_net # For modem/ipx support.
  ];

  preConfigure = ''
    ./autogen.sh
  '';

  preBuild = let
    CXXFLAGS = "-O3 -DNDEBUG";
  in ''
    buildFlagsArray=( "CXXFLAGS=${CXXFLAGS}" )
  '';

  desktopItem = makeDesktopItem {
    name = "dosbox-staging";
    exec = "dosbox";
    icon = "dosbox-staging";
    comment = meta.description;
    desktopName = "DOSBox-Staging";
    genericName = "DOS emulator";
    categories = "Application;Emulator;";
  };

  postInstall = ''
     install -Dm755 -t $out/share/man/man1 docs/*.1
     mkdir -p $out/share/applications
     cp ${desktopItem}/share/applications/* $out/share/applications
     mkdir -p $out/share/icons/hicolor/256x256/apps
     gm convert src/dosbox.ico $out/share/icons/hicolor/256x256/apps/dosbox.png
  '';

  meta = with stdenv.lib; {
    description = "A modernized DOS emulator";
    downloadPage = https://github.com/dreamer/dosbox-staging/releases;
    homepage = https://github.com/dreamer/dosbox-staging;
    license = licenses.gpl2;
    longDescription = ''
    This repository attempts to modernize the DOSBox project by using current development practices and tools, fixing issues, adding features that better support today's systems, and sending patches upstream.
    '';
    maintainers = with maintainers; [ joshuafern ];
    platforms = platforms.unix;
  };
}
