{
  lib,
  stdenv,
  fetchpatch,
  cmake,
  pkg-config,
  pins,
  ffmpeg,
  libebur128,
  taglib,
  zlib,
}:
stdenv.mkDerivation rec {
  pname = "loudgain";
  version = "unstable-2020-12-28";

  src = pins.loudgain.outPath;

  patches = [
    (fetchpatch {
      # See loudgain PR #50
      url = "https://github.com/hughmcmaster/loudgain/commit/977332e9e45477b1b41a5af7a2484f92b340413b.patch";
      sha256 = "sha256-h6SduvURdmyNb1X8I8g6MDaes9aNshWd0ifwWJhVTzw=";
      name = "loudgain-ffmpeg5.patch";
    })
    (fetchpatch {
      # See loudgain PR #65
      url = "https://github.com/hughmcmaster/loudgain/commit/ad9c7f8ddf0907d408b3d2fbf4d00ecb55af8d13.patch";
      sha256 = "sha256-7BJ8Za6T4KpMCvPMhEddAqv5YzndTLW/Tid6im5jpIc=";
      name = "loudgain-gcc14.patch";
    })
    (fetchpatch {
      # See loudgain PR #66
      url = "https://github.com/hughmcmaster/loudgain/commit/50741b98fb4b932759f05e8d208d80d93bcc8261.patch";
      sha256 = "sha256-A05pVQ+hUZBgSSU2OvclyOHmpxG7qRpcpJ2ThUGhC+s=";
      name = "loudgain-ffmpeg7.patch";
    })
  ];

  # CMake 2.8 is deprecated and is no longer supported by CMake > 4
  # https://github.com/NixOS/nixpkgs/issues/445447
  postPatch = ''
    substituteInPlace CMakeLists.txt --replace-fail \
      "CMAKE_MINIMUM_REQUIRED(VERSION 2.8)" \
      "CMAKE_MINIMUM_REQUIRED(VERSION 3.10)"
  '';

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    ffmpeg
    libebur128
    taglib
    zlib
  ];

  meta = with lib; {
    description = "ReplayGain 2.0 loudness normalizer based on the EBU R128/ITU BS.1770 standard";
    homepage = "https://github.com/Moonbase59/loudgain";
    maintainers = with maintainers; [ arobyn ];
    platforms = [ "x86_64-linux" ];
    license = licenses.bsd2;
  };
}
