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

  configurePhase = ''
      (cd src && cmakeConfigurePhase)
  '';

  cmakeFlags = [
    "-DBUILD_PRESET=everything"
    "-DENABLE_SIMD=On"
    "-DHYBRID_SDL=On"
  ];

  NIX_CFLAGS_COMPILE="-O2 -Wformat";

  buildPhase = ''
    cd src/build
    make
  '';

  meta = with stdenv.lib; {
    homepage = "https://www.arcan-fe.com";
    description = "Next Generation Display Server";
    platforms = platforms.linux;
    maintainers = [ "chris@oboe.email" ];
  };
}

