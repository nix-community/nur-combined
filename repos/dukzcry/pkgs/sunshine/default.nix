{ lib, stdenv, fetchFromGitHub, cmake, boost, openssl, ffmpeg, pkg-config, libopus
, libX11, libXfixes, libXrandr, libpulseaudio, libevdev, mesa, makeWrapper, libdrm
, wayland, avahi, libGL }:

stdenv.mkDerivation rec {
  pname = "sunshine";
  version = "0.14.0";

  src = fetchFromGitHub {
    owner = "SunshineStream";
    repo = "Sunshine";
    rev = "v${version}";
    sha256 = "sha256-W9FzA8HCbHM4r2XNrZJejrqbPnNhT9x64cuVZpJRjHY=";
    fetchSubmodules = true;
  };

  cmakeFlags = [
    "-DSUNSHINE_ASSETS_DIR=${placeholder "out"}/etc/sunshine"
    "-DSUNSHINE_CONFIG_DIR=${placeholder "out"}/etc/sunshine"
  ];

  patches = [ ./sunshine.patch ];

  hardeningDisable = [ "format" ];

  nativeBuildInputs = [ cmake pkg-config makeWrapper ];
  buildInputs = [
    openssl boost ffmpeg libopus libX11 libXfixes libXrandr libpulseaudio
    libevdev libdrm wayland
  ];

  preConfigure = ''
    substituteInPlace CMakeLists.txt \
      --replace "Boost_USE_STATIC_LIBS ON" "Boost_USE_STATIC_LIBS OFF" \
      --replace "Boost::log" "Boost::log Boost::dynamic_linking" \
      --replace "/usr/include/libevdev-1.0" "${libevdev}/include/libevdev-1.0" \
      --replace "/etc/udev/rules.d" "$out/etc/udev/rules.d" \
      --replace "/usr/bin" "$out/bin" \
      --replace "/usr/lib/systemd/user" "$out/lib/systemd/user"
  '';

  postInstall = ''
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
