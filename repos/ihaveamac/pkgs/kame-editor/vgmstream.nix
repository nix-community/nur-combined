# This is the same as the file from nixpkgs but with audacious removed, due to no macOS support.
# https://github.com/NixOS/nixpkgs/blob/f771eb401a46846c1aebd20552521b233dd7e18b/pkgs/by-name/vg/vgmstream/package.nix
{
  stdenv,
  lib,
  fetchzip,
  fetchFromGitHub,
  cmake,
  pkg-config,
  mpg123,
  ffmpeg,
  libvorbis,
  libao,
  speex,
  nix-update-script,
}:

let
  # https://github.com/vgmstream/vgmstream/blob/1b6a7915bf98ca14a71a0d44bef7a2c6a75c686d/cmake/dependencies/atrac9.cmake
  atrac9-src = fetchFromGitHub {
    owner = "Thealexbarney";
    repo = "LibAtrac9";
    rev = "6a9e00f6c7abd74d037fd210b6670d3cdb313049";
    hash = "sha256-n47CzIbh8NxJ4GzKLjZQeS27k2lGx08trC1m4AOzVZc=";
  };

  # https://github.com/vgmstream/vgmstream/blob/1b6a7915bf98ca14a71a0d44bef7a2c6a75c686d/cmake/dependencies/celt.cmake
  celt-0_6_1-src = fetchzip {
    url = "https://downloads.xiph.org/releases/celt/celt-0.6.1.tar.gz";
    hash = "sha256-DI1z10mTDQOn/R1FssaegmOa6ZNx3bXNiWHwLnytJWw=";
  };
  celt-0_11_0-src = fetchzip {
    url = "https://downloads.xiph.org/releases/celt/celt-0.11.0.tar.gz";
    hash = "sha256-JI3b44iCxQ29bqJGNH/L18pEuWiTFZ2132ceaqe8U0E=";
  };
in

stdenv.mkDerivation rec {
  pname = "vgmstream";
  version = "1980";

  src = fetchFromGitHub {
    owner = "vgmstream";
    repo = "vgmstream";
    tag = "r${version}";
    hash = "sha256-TmaWC04XbtFfBYhmTO4ouh3NoByio1BCpDJGJy3r0NY=";
  };

  passthru.updateScript = nix-update-script {
    attrPath = "vgmstream";
    extraArgs = [
      "--version-regex"
      "r(.*)"
    ];
  };

  outputs = [
    "out"
  ];

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    mpg123
    ffmpeg
    libvorbis
    libao
    speex
  ];

  preConfigure =
    ''
    ''
    +
      # cmake/dependencies/celt.cmake uses configure_file to modify ${CELT_0110_PATH}/libcelt/ecintrin.h.
      # Therefore, CELT_0110_PATH needs to point to a mutable directory.
      lib.optionalString (stdenv.system == "x86_64-linux") ''
        mkdir -p dependencies/celt-0.11.0/
        cp -r ${celt-0_11_0-src}/* dependencies/celt-0.11.0/
        chmod -R +w dependencies/celt-0.11.0/
      '';

  cmakeFlags =
    [
      "-DATRAC9_PATH=${atrac9-src}"
      "-DBUILD_AUDACIOUS=OFF"
    ]
    # Only supported on x86_64-linux
    ++ lib.optionals (stdenv.system == "x86_64-linux") [
      "-DCELT_0061_PATH=${celt-0_6_1-src}"
      "-DCELT_0110_PATH=../dependencies/celt-0.11.0"
      # libg719_decode omitted because it doesn't have a free software license
    ];

  meta = with lib; {
    description = "Library for playback of various streamed audio formats used in video games";
    homepage = "https://vgmstream.org";
    maintainers = with maintainers; [ zane ];
    license =
      with licenses;
      [
        isc # vgmstream itself
        mit # atrac9
      ]
      ++ optional (stdenv.system == "x86_64-linux") bsd2;
    platforms = with platforms; unix;
  };
}
