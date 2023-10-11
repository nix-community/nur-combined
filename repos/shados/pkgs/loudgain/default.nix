{ lib, stdenv
, fetchpatch
, cmake, pkg-config, pins
, ffmpeg, libebur128, taglib, zlib
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
  ];

  nativeBuildInputs = [
    cmake pkg-config
  ];

  buildInputs = [
    ffmpeg libebur128 taglib zlib
  ];

  meta = with lib; {
    description = "ReplayGain 2.0 loudness normalizer based on the EBU R128/ITU BS.1770 standard";
    homepage    = https://github.com/Moonbase59/loudgain;
    maintainers = with maintainers; [ arobyn ];
    platforms   =  [ "x86_64-linux" ];
    license     = licenses.bsd2;
  };
}
