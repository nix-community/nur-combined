{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  nasm,
  cpuinfo,
  libdovi,
  hdr10plus ? null,

}:

stdenv.mkDerivation (finalAttrs: {
  pname = "svt-av1-psyex";
  version = "3.0.2-A";

  src = fetchFromGitHub {
    owner = "BlueSwordM";
    repo = "svt-av1-psyex";
    rev = "v${finalAttrs.version}";
    hash = "sha256-oZMBuC8NZw8QaKCPk5q+S9S2yaMn9UVlvWMsqadtM/4=";
  };

  nativeBuildInputs = [
    cmake
    nasm
  ];
  makeBuildType = "Release";

  buildInputs = [
    cpuinfo
    libdovi
  ]
  ++ 
  (lib.optionals (hdr10plus!=null) [hdr10plus]);

  cmakeFlags = [
    "-DSVT_AV1_LTO=ON"
    "-DUSE_EXTERNAL_CPUINFO=ON"
    "-DLIBDOVI_FOUND=ON"
  ]
  ++
  (lib.optionals (hdr10plus!=null) ["-DLIBHDR10PLUS_RS_FOUND=ON"]);

  meta = with lib; {
    homepage = "https://github.com/gianni-rosato/svt-av1-psy";
    description = "The Scalable Video Technology for AV1 (SVT-AV1 Encoder and Decoder) with perceptual enhancements for psychovisually optimal AV1 encoding";

    longDescription = ''
      SVT-AV1-PSY is the Scalable Video Technology for AV1 (SVT-AV1 Encoder and Decoder) with perceptual enhancements for psychovisually optimal AV1 encoding.
      The goal is to create the best encoding implementation for perceptual quality with AV1.
    '';

    license = with licenses; [
      aom
      bsd3
    ];
    platforms = platforms.unix;
  };
})
