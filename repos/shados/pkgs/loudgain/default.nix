{ lib, stdenv
, fetchpatch
, cmake, pkgconfig, pins
, ffmpeg, libebur128, taglib, zlib
}:
stdenv.mkDerivation rec {
  pname = "loudgain";
  version = "unstable-2020-12-28";

  src = pins.loudgain.outPath;

  patches = [
    (fetchpatch {
      url = "https://github.com/Moonbase59/loudgain/pull/50.patch";
      sha256 = "sha256-2TgkhCvs3ZrEAu7e876iXbmT8hIM+ybdYiRoB7uCa4Q=";
      name = "loudgain-ffmpeg5.patch";
    })
  ];

  nativeBuildInputs = [
    cmake pkgconfig
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
