{ stdenv
, lib
, fetchzip
, zlib
, xorg
, libglvnd
, libGLU
, autoPatchelfHook
, libpulseaudio
, alsa-lib
}:

stdenv.mkDerivation rec {
  pname = "dont-take-it-personally-babe";
  version = "1.1";

  src = fetchzip {
    url = "https://scoutshonour.com/donttakeitpersonallybabeitjustaintyourstory/don't%20take%20it%20personally,%20babe-${version}-linux-x86.tar.bz2";
    sha256 = "X1xAJS8SrsQ5yrValrlfmeRLtSiH94EUw++GWjstwdc=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
  ];

  buildInputs = [
    zlib
    xorg.libX11
    xorg.libXext
    libglvnd
    libGLU
    xorg.libXi
    xorg.libXmu
  ];

  appendRunpaths = [
    "${xorg.libX11}/lib"
    "${xorg.libXext}/lib"
    "${xorg.libXrender}/lib"
    "${xorg.libXrandr}/lib"
    "${libpulseaudio}/lib"
    "${alsa-lib}/lib"
  ];

  sourceRoot = ".";

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    # copy distributed files
    mkdir -p $out/opt/donttakeitpersonallybabeitjustaintyourstory
    cp -R source/* $out/opt/donttakeitpersonallybabeitjustaintyourstory

    # add launcher
    mkdir -p $out/bin
    substituteAll ${./launcher.sh} $out/bin/donttakeitpersonallybabeitjustaintyourstory
    chmod +x $out/bin/donttakeitpersonallybabeitjustaintyourstory

    # add desktop file
    mkdir -p $out/share/applications
    substituteAll ${./donttakeitpersonallybabeitjustaintyourstory.desktop} $out/share/applications/donttakeitpersonallybabeitjustaintyourstory.desktop

    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://scoutshonour.com/donttakeitpersonallybabeitjustaintyourstory/";
    description = "don't take it personally, babe, it just ain't your story: a freeware game by Christine Love";
    license = licenses.cc-by-nc-sa-30;
    platforms = lists.intersectLists platforms.x86 platforms.linux;
  };
}
