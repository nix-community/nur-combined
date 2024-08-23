{ lib
, stdenv
, fetchFromGitHub
, cmake
, nasm

}:

stdenv.mkDerivation (finalAttrs: {
  pname = "svt-av1-psy";
  version = "2.2.0";

  src = fetchFromGitHub {
    owner = "gianni-rosato";
    repo = "svt-av1-psy";
    rev = "v${finalAttrs.version}";
    hash = "sha256-NWEX7KyQbpUrMbDBQaJWindod85cLUeNqwEpaDPtWUw=";
  };

  nativeBuildInputs = [
    cmake
    nasm
  ];

  cmakeFlags = [
    "-DSVT_AV1_LTO=ON"
  ];

  meta = with lib; {
    homepage = "https://github.com/gianni-rosato/svt-av1-psy";
    description = "The Scalable Video Technology for AV1 (SVT-AV1 Encoder and Decoder) with perceptual enhancements for psychovisually optimal AV1 encoding";

    longDescription = ''
      SVT-AV1-PSY is the Scalable Video Technology for AV1 (SVT-AV1 Encoder and Decoder) with perceptual enhancements for psychovisually optimal AV1 encoding.
      The goal is to create the best encoding implementation for perceptual quality with AV1.
    '';

    license = with licenses; [ aom bsd3 ];
    platforms = platforms.unix;
  };
})
