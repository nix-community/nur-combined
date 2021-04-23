# not working nicely yet

{ stdenv
, fetchFromGitHub
, cmake
, pkgconfig
, apr
, ffmpeg
, harfbuzz
, glib
, lzma
, openal
, libusb
, luajit
, freetype
, pcre
, libGL
, libdrm
, libvncserver
, libxkbcommon
, sqlite
, vlc
, mesa
, libX11
}:

stdenv.mkDerivation rec {
  name = "arcan-${version}";
  version = "0.6.0-pre2";
  src = fetchFromGitHub {
    owner = "letoram";
    repo = "arcan";
    rev = version;
    sha256 = "04g6z367kkn9fr6vb43m959a0ydrxbfxgivsxq3yv9ri4j81a8nh";
  };

  nativeBuildInputs = [ cmake pkgconfig ];
  buildInputs = [
    ffmpeg
    harfbuzz
    apr
    lzma
    openal
    libusb
    mesa
    glib
    luajit
    freetype
    libGL
    libdrm
    pcre
    libvncserver
    libxkbcommon
    sqlite
    vlc
    libX11
  ];

  postPatch = ''
    substituteInPlace src/CMakeLists.txt --replace SETUID ""
  '';

  dontUseCmakeBuildDir = true;
  cmakeDir = "./src";
  cmakeFlags = ''
    -DDISTR_TAG=Nixpkgs
    -DVIDEO_PLATFORM=egl-dri
    -DENGINE_BUILDTAG=${src.rev}
  '';

  preConfigure = ''
    CMAKE_INCLUDE_PATH=$CMAKE_INCLUDE_PATH:${libdrm.dev}/include/libdrm
  '';

  enableParallelBuilding = true;
  hardeningDisable = [ "format" ];

  meta = with stdenv.lib; {
    homepage = https://arcan-fe.com;
    description = "Combined display server, multimedia framework and game engine";
    license = with licenses; [ gpl2Plus lgpl2Plus bsd3 ];
    platforms = platforms.linux;
    maintainers = [ maintainers.gazally ];
  };
}
