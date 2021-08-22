{ stdenv, lib, fetchFromGitHub, pkg-config, cmake, ninja
, boost, wayland, egl-wayland, libglvnd, glm, protobuf
, capnproto, glog, lttng-ust, libudev, glib, xorg
, libdrm, mesa, epoxy, nettle, libxkbcommon, libinput
, libxmlxx, libuuid, freetype, libyamlcpp, python3Packages
, libevdev, umockdev, gtest, lcov, gcovr, wlcs, doxygen
, libsystemtap
}:

with lib;

stdenv.mkDerivation rec {
  pname = "mir";
  version = "2.4.1";

  src = fetchFromGitHub {
    owner = "MirServer";
    repo = "mir";
    rev = "v${version}";
    sha256 = "KE2vnSEt8TlVq/dJkrLyQyj3r6wc8kFPxhLUe154nfc=";
  };

  nativeBuildInputs = [ pkg-config cmake ninja doxygen ];

  buildInputs = [
    boost wayland egl-wayland libglvnd glm protobuf
    capnproto glog lttng-ust libudev glib xorg.libxcb
    xorg.libX11 xorg.libXcursor xorg.xorgproto libdrm
    mesa epoxy nettle libxkbcommon libinput libxmlxx
    libuuid freetype libyamlcpp python3Packages.pillow
    libevdev umockdev gtest lcov gcovr wlcs libsystemtap
  ];

  cmakeFlags = [
    "-DCMAKE_INSTALL_LIBDIR=lib"
    "-DCMAKE_INSTALL_INCLUDEDIR=include"
  ];

  enableParallelBuilding = true;

  meta = {
    description = "The Mir compositor";
    longDescription = ''
      Mir is set of libraries for building Wayland based shells.
      Mir simplifies the complexity that shell authors need to deal with:
      it provides a stable, well tested and performant platform with touch,
      mouse and tablet input, multi-display capability and secure client-server
      communications.
    '';
    license = [ licenses.gpl2Only licenses.gpl3Only licenses.lgpl2Only licenses.lgpl3Only ];
    platforms = platforms.linux;
    homepage = https://mir-server.io;
    changelog = "https://github.com/MirServer/mir/releases/tag/v{version}";
    maintainers = with maintainers; [ ilya-fedin ];
  };
}
