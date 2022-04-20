{ lib, stdenv, fetchFromGitHub, cmake, boost, openssl, ffmpeg, pkgconfig, libopus
, libX11, libXfixes, libXrandr, libpulseaudio, libevdev, mesa, makeWrapper, libdrm
, wayland, avahi, libGL }:

stdenv.mkDerivation rec {
  pname = "sunshine";
  version = "0.13.0";

  src = fetchFromGitHub {
    owner = "SunshineStream";
    repo = "Sunshine";
    rev = "v${version}";
    sha256 = "1nwm2v62gpxs5wyyyxgj24xkf3hsbvfmj7pycdzp526kkv9l1yxm";
    fetchSubmodules = true;
  };

  cmakeFlags = [
    "-DSUNSHINE_ASSETS_DIR=$(out)/etc/sunshine"
    "-DSUNSHINE_CONFIG_DIR=/etc/sunshine"
  ];

  hardeningDisable = [ "format" ];

  nativeBuildInputs = [ cmake pkgconfig makeWrapper ];
  buildInputs = [
    openssl boost ffmpeg libopus libX11 libXfixes libXrandr libpulseaudio
    libevdev libdrm wayland
  ];

  preConfigure = ''
    substituteInPlace CMakeLists.txt \
      --replace "Boost_USE_STATIC_LIBS ON" "Boost_USE_STATIC_LIBS OFF" \
      --replace "Boost::log" "Boost::log Boost::dynamic_linking" \
      --replace "/usr/include/libevdev-1.0" "${libevdev}/include/libevdev-1.0" \
  '';

  installPhase = ''
    install -Dm755 sunshine $out/bin/sunshine
    install -Dm644 $src/assets/apps_linux.json $out/etc/sunshine/apps_linux.json
    install -Dm644 $src/assets/sunshine.conf $out/etc/sunshine/sunshine.conf
    cp -r $src/assets/web $out/etc/sunshine
    mkdir -p $out/etc/sunshine/shaders
    cp -r $src/assets/shaders/opengl $out/etc/sunshine/shaders

    wrapProgram $out/bin/sunshine \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath [ avahi mesa libGL ]}"
  '';

  meta = with lib; {
    description = "Host for Moonlight Streaming Client";
    license = licenses.gpl3;
    homepage = src.meta.homepage;
    platforms = platforms.linux;
    maintainers = with maintainers; [ ];
  };
}
