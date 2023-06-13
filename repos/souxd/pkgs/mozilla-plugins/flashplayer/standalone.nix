{ stdenv
, lib
, fetchurl
, makeDesktopItem
, alsaLib
, atk
, bzip2
, cairo
, curl
, expat
, fontconfig
, freetype
, gdk-pixbuf
, glib
, glibc
, graphite2
, gtk2
, harfbuzz
, libICE
, libSM
, libX11
, libXau
, libXcomposite
, libXcursor
, libXdamage
, libXdmcp
, libXext
, libXfixes
, libXi
, libXinerama
, libXrandr
, libXrender
, libXt
, libXxf86vm
, libdrm
, libffi
, libglvnd
, libpng
, libvdpau
, libxcb
, libxshmfence
, nspr
, nss
, pango
, pcre
, pixman
, zlib
, unzip
, debug ? false
}:

stdenv.mkDerivation rec {
  name = "flashplayer-standalone-${version}";
  pname = "flashplayer-standalone";
  version = "32.0.0.465";

  src = fetchurl {
    url =
      if debug then
        "http://web.archive.org/web/20201231144810/https://fpdownload.macromedia.com/pub/flashplayer/updaters/32/flash_player_sa_linux_debug.x86_64.tar.gz"
      else
        "http://web.archive.org/web/20201231144810/https://fpdownload.macromedia.com/pub/flashplayer/updaters/32/flash_player_sa_linux.x86_64.tar.gz";
    sha256 =
      if debug then
        "1ija3z5bxg0ppx9r237cxs1cdrhk6pia2kcxbrm6y30kvzrd3nqs"
      else
        "1hwnvwph7p3nfv2xf7kjw3zdpb546dsia0cmhzg81z016fi7lgw8";
  };

  nativeBuildInputs = [ unzip ];
  sourceRoot = ".";
  dontStrip = true;
  dontPatchELF = true;
  preferLocalBuild = true;
  installPhase = ''
    mkdir -p $out/bin
    mv flashplayer${lib.optionalString debug "debugger"} $out/bin
    patchelf \
      --set-interpreter $(cat $NIX_CC/nix-support/dynamic-linker) \
      --set-rpath "$rpath" \
      $out/bin/flashplayer${lib.optionalString debug "debugger"}
    cp -r ${desktopItems}/share $out
  '';

  rpath = lib.makeLibraryPath
    [ stdenv.cc.cc
      alsaLib atk bzip2 cairo curl expat fontconfig freetype gdk-pixbuf glib
      glibc graphite2 gtk2 harfbuzz libICE libSM libX11 libXau libXcomposite
      libXcursor libXdamage libXdmcp libXext libXfixes libXi libXinerama
      libXrandr libXrender libXt libXxf86vm libdrm libffi libglvnd libpng
      libvdpau libxcb libxshmfence nspr nss pango pcre pixman zlib
    ];

  desktopItems = makeDesktopItem rec {
    name = pname;
    desktopName = "Flash Player";
    comment = "Run Adobe Flash locally";
    keywords = [
      "Flash"
      "Adobe"
      "Projector"
    ];
    exec = "flashplayer %u";
    terminal = false;
    type = "Application";
    categories = [
      "Audio"
      "AudioVideo"
      "Graphics"
      "GTK"
      "Player"
      "Video"
      "Viewer"
    ];
    mimeTypes = [
      "application/vnd.adobe.flash.movie"
      "image/gif"
      "image/jpg"
      "image/png"
    ];
    startupNotify = false;
    startupWMClass = "Flash Player";
    extraConfig = {
      X-MultipleArgs = "false";
    };
  };

  meta = with lib; {
    description = "Adobe Flash Player Standalone (A.K.A. Adobe Flash Player Projector)";
    homepage = https://archive.org/details/flashplayerarchive;
    license = licenses.unfree;
    maintainers = [];
    platforms = [ "x86_64-linux" ];
    # Application crashed with an unhandled SIGSEGV
    # Not on all systems, though. Video driver problem?
    broken = false;
  };
}
