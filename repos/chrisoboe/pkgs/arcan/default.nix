{ stdenv, fetchFromGitHub, cmake, pkg-config, ffmpeg, file, freetype, harfbuzz
, leptonica, libdrm, libffi, libusb1, libvlc, libvncserver, libxcb, libXdmcp
, libxkbcommon, luajit, lzma, mesa, openal, SDL2, sqlite, tesseract, wayland
, xcbutil, xcbutilwm, xcbutilxrm, xwayland, }:

stdenv.mkDerivation rec {
  pname = "arcan";
  version = "0.6.0.1";

  src = fetchFromGitHub {
    owner = "letoram";
    repo = "arcan";
    rev = "${version}";
    sha256 = "1kghiixv1yvy4zhyzspvvxs4kg20a9baxkzf50wl4y00l76ciw58";
  };

  nativeBuildInputs = [ cmake pkg-config ];

  buildInputs = [
    ffmpeg
    file
    freetype
    harfbuzz
    leptonica
    libdrm
    libffi
    libusb1
    libvlc
    libvncserver
    libxcb
    libXdmcp
    libxkbcommon
    luajit
    lzma
    mesa
    openal
    SDL2
    sqlite
    tesseract
    wayland
    xcbutil
    xcbutilwm
    xcbutilxrm
    xwayland
  ];

  patchPhase = ''
    sed -i "s,SETUID,,g" ./src/CMakeLists.txt
    substituteInPlace ./src/platform/posix/paths.c \
      --replace "/usr/bin" "$out/bin" \
      --replace "/usr/share" "$out/share"
  '';

  configurePhase = ''
    (cd src && cmakeConfigurePhase)
  '';

  cmakeFlags = [
    "-DBUILD_PRESET=everything"
    "-DENABLE_SIMD=On"
    "-DHYBRID_SDL=On"
    "-DHYBRID_HEADLESS=On"
  ];

  NIX_CFLAGS_COMPILE = "-O2 -Wformat";

  buildPhase = ''
    cd src/build
    make
  '';

  # don't create wrapper, since wrappers are shell scripts, so they can't be suid-wrapped anymore
  # lets rather patch arcan itself to look for the proper search paths
  # postFixup = ''
  #   wrapProgram $out/bin/arcan --set-default ARCAN_RESOURCEPATH $out/share/arcan/resources --set-default ARCAN_SCRIPTPATH $out/share/arcan/scripts --set-default ARCAN_APPLBASEPATH $out/share/arcan/appl --set-default ARCAN_APPLSTOREPATH $out/share/arcan/appl --set-default ARCAN_APPLTEMPPATH /var/lib/arcan/appl --set-default ARCAN_BINPATH $out/bin
  #   wrapProgram $out/bin/arcan_db --set-default ARCAN_RESOURCEPATH $out/share/arcan/resources --set-default ARCAN_SCRIPTPATH $out/share/arcan/scripts --set-default ARCAN_APPLBASEPATH $out/share/arcan/appl --set-default ARCAN_APPLSTOREPATH $out/share/arcan/appl --set-default ARCAN_APPLTEMPPATH /var/lib/arcan/appl --set-default ARCAN_BINPATH $out/bin
  #   wrapProgram $out/bin/arcan_frameserver --set-default ARCAN_RESOURCEPATH $out/share/arcan/resources --set-default ARCAN_SCRIPTPATH $out/share/arcan/scripts --set-default ARCAN_APPLBASEPATH $out/share/arcan/appl --set-default ARCAN_APPLSTOREPATH $out/share/arcan/appl --set-default ARCAN_APPLTEMPPATH /var/lib/arcan/appl --set-default ARCAN_BINPATH $out/bin
  #   wrapProgram $out/bin/arcan_headless --set-default ARCAN_RESOURCEPATH $out/share/arcan/resources --set-default ARCAN_SCRIPTPATH $out/share/arcan/scripts --set-default ARCAN_APPLBASEPATH $out/share/arcan/appl --set-default ARCAN_APPLSTOREPATH $out/share/arcan/appl --set-default ARCAN_APPLTEMPPATH /var/lib/arcan/appl --set-default ARCAN_BINPATH $out/bin
  #   wrapProgram $out/bin/arcan-net --set-default ARCAN_RESOURCEPATH $out/share/arcan/resources --set-default ARCAN_SCRIPTPATH $out/share/arcan/scripts --set-default ARCAN_APPLBASEPATH $out/share/arcan/appl --set-default ARCAN_APPLSTOREPATH $out/share/arcan/appl --set-default ARCAN_APPLTEMPPATH /var/lib/arcan/appl --set-default ARCAN_BINPATH $out/bin
  #   wrapProgram $out/bin/arcan_sdl --set-default ARCAN_RESOURCEPATH $out/share/arcan/resources --set-default ARCAN_SCRIPTPATH $out/share/arcan/scripts --set-default ARCAN_APPLBASEPATH $out/share/arcan/appl --set-default ARCAN_APPLSTOREPATH $out/share/arcan/appl --set-default ARCAN_APPLTEMPPATH /var/lib/arcan/appl --set-default ARCAN_BINPATH $out/bin
  #   wrapProgram $out/bin/arcan-wayland --set-default ARCAN_RESOURCEPATH $out/share/arcan/resources --set-default ARCAN_SCRIPTPATH $out/share/arcan/scripts --set-default ARCAN_APPLBASEPATH $out/share/arcan/appl --set-default ARCAN_APPLSTOREPATH $out/share/arcan/appl --set-default ARCAN_APPLTEMPPATH /var/lib/arcan/appl --set-default ARCAN_BINPATH $out/bin
  #   wrapProgram $out/bin/arcan_xwm --set-default ARCAN_RESOURCEPATH $out/share/arcan/resources --set-default ARCAN_SCRIPTPATH $out/share/arcan/scripts --set-default ARCAN_APPLBASEPATH $out/share/arcan/appl --set-default ARCAN_APPLSTOREPATH $out/share/arcan/appl --set-default ARCAN_APPLTEMPPATH /var/lib/arcan/appl --set-default ARCAN_BINPATH $out/bin
  # '';

  meta = with stdenv.lib; {
    homepage = "https://www.arcan-fe.com";
    description = "Next Generation Display Server";
    platforms = platforms.linux;
    maintainers = [ "chris@oboe.email" ];
  };
}

