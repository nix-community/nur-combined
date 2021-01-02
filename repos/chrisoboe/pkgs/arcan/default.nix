{ stdenv, fetchFromGitHub, cmake, pkg-config, libdrm, mesa, file, libxkbcommon, libXdmcp, wayland, xwayland, libffi, lzma, libxcb, xcbutil, xcbutilwm, xcbutilxrm, sqlite, openal, SDL2, luajit, freetype, harfbuzz, libvlc, ffmpeg, leptonica, tesseract, libvncserver, libusb1 }:

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

  buildInputs = [ libdrm mesa sqlite openal SDL2 luajit freetype harfbuzz file libxkbcommon libXdmcp wayland xwayland libffi lzma libxcb xcbutil xcbutilwm xcbutilxrm libvlc ffmpeg leptonica tesseract libvncserver libusb1];

  patches = [
    ./no-suid.patch
  ];
  #doCheck = false; # needs suid

  configurePhase = ''
      (cd src && cmakeConfigurePhase)
  '';

  cmakeFlags = [
    "-DBUILD_PRESET=everything"
    "-DENABLE_SIMD=On"
    "-DHYBRID_SDL=On"
    "-DHYBRID_HEADLESS=On"
  ];

  NIX_CFLAGS_COMPILE="-O2 -Wformat";

  buildPhase = ''
    cd src/build
    make
  '';

  postFixup = ''
    wrapProgram $out/bin/arcan --set-default ARCAN_RESOURCEPATH $out/share/arcan/resources --set-default ARCAN_SCRIPTPATH $out/share/arcan/scripts --set-default ARCAN_APPLBASEPATH $out/share/arcan/appl --set-default ARCAN_APPLSTOREPATH $out/share/arcan/appl --set-default ARCAN_APPLTEMPPATH /var/lib/arcan/appl --set-default ARCAN_BINPATH $out/bin
    wrapProgram $out/bin/arcan_db --set-default ARCAN_RESOURCEPATH $out/share/arcan/resources --set-default ARCAN_SCRIPTPATH $out/share/arcan/scripts --set-default ARCAN_APPLBASEPATH $out/share/arcan/appl --set-default ARCAN_APPLSTOREPATH $out/share/arcan/appl --set-default ARCAN_APPLTEMPPATH /var/lib/arcan/appl --set-default ARCAN_BINPATH $out/bin
    wrapProgram $out/bin/arcan_frameserver --set-default ARCAN_RESOURCEPATH $out/share/arcan/resources --set-default ARCAN_SCRIPTPATH $out/share/arcan/scripts --set-default ARCAN_APPLBASEPATH $out/share/arcan/appl --set-default ARCAN_APPLSTOREPATH $out/share/arcan/appl --set-default ARCAN_APPLTEMPPATH /var/lib/arcan/appl --set-default ARCAN_BINPATH $out/bin
    wrapProgram $out/bin/arcan_headless --set-default ARCAN_RESOURCEPATH $out/share/arcan/resources --set-default ARCAN_SCRIPTPATH $out/share/arcan/scripts --set-default ARCAN_APPLBASEPATH $out/share/arcan/appl --set-default ARCAN_APPLSTOREPATH $out/share/arcan/appl --set-default ARCAN_APPLTEMPPATH /var/lib/arcan/appl --set-default ARCAN_BINPATH $out/bin
    wrapProgram $out/bin/arcan-net --set-default ARCAN_RESOURCEPATH $out/share/arcan/resources --set-default ARCAN_SCRIPTPATH $out/share/arcan/scripts --set-default ARCAN_APPLBASEPATH $out/share/arcan/appl --set-default ARCAN_APPLSTOREPATH $out/share/arcan/appl --set-default ARCAN_APPLTEMPPATH /var/lib/arcan/appl --set-default ARCAN_BINPATH $out/bin
    wrapProgram $out/bin/arcan_sdl --set-default ARCAN_RESOURCEPATH $out/share/arcan/resources --set-default ARCAN_SCRIPTPATH $out/share/arcan/scripts --set-default ARCAN_APPLBASEPATH $out/share/arcan/appl --set-default ARCAN_APPLSTOREPATH $out/share/arcan/appl --set-default ARCAN_APPLTEMPPATH /var/lib/arcan/appl --set-default ARCAN_BINPATH $out/bin
    wrapProgram $out/bin/arcan-wayland --set-default ARCAN_RESOURCEPATH $out/share/arcan/resources --set-default ARCAN_SCRIPTPATH $out/share/arcan/scripts --set-default ARCAN_APPLBASEPATH $out/share/arcan/appl --set-default ARCAN_APPLSTOREPATH $out/share/arcan/appl --set-default ARCAN_APPLTEMPPATH /var/lib/arcan/appl --set-default ARCAN_BINPATH $out/bin
    wrapProgram $out/bin/arcan_xwm --set-default ARCAN_RESOURCEPATH $out/share/arcan/resources --set-default ARCAN_SCRIPTPATH $out/share/arcan/scripts --set-default ARCAN_APPLBASEPATH $out/share/arcan/appl --set-default ARCAN_APPLSTOREPATH $out/share/arcan/appl --set-default ARCAN_APPLTEMPPATH /var/lib/arcan/appl --set-default ARCAN_BINPATH $out/bin
  '';

  meta = with stdenv.lib; {
    homepage = "https://www.arcan-fe.com";
    description = "Next Generation Display Server";
    platforms = platforms.linux;
    maintainers = [ "chris@oboe.email" ];
  };
}

