{ stdenv
, lib
, fetchFromGitHub
, wrapQtAppsHook
, cmake
, pkg-config
, python3
, glslang
, libpthreadstubs
, zlib
, openssl
, curl
, libuv
, libffi
, c-ares
, vulkan-headers
, vulkan-loader
, ffmpeg
, SDL2
, qtbase
, qtsvg
}:

let
  decaf-emu = stdenv.mkDerivation rec {
    pname = "decaf-emu";
    version = "unstable";
    name = "${pname}-${version}";

    src = fetchFromGitHub {
      owner = "decaf-emu";
      repo = "decaf-emu";
      fetchSubmodules = true;
      rev = "0cd56a2faa3b0f7d3f447a39ba9ad8449666e2f9";
      sha256 = "1ab1ld00vczzndb3iy7i8zll4175gx20zgz003n5f03113jpr3as";
    };

    depsBuildBuild = [
      pkg-config
    ];

    nativeBuildInputs = [
      cmake
      pkg-config
      python3
      glslang
      wrapQtAppsHook
    ];

    buildInputs = [
      libpthreadstubs
      zlib
      openssl
      curl
      libuv
      libffi
      c-ares
      vulkan-headers
      vulkan-loader
      ffmpeg
      SDL2
      qtbase
      qtsvg
    ];

    cmakeFlags = [
      "-Wno-dev"
      "-DDECAF_QT=ON"
    ];

    meta = with lib; {
      description = "Researching Wii U emulation";
      homepage = "https://github.com/decaf-emu/decaf-emu";
      license = licenses.gpl3;
      platforms = platforms.linux;
      broken = true;
    };
  };
in
decaf-emu
