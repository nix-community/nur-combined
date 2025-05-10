{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  pkg-config,
  glib,
  libacars,
  protobufc,
  rtl-sdr,
  soapysdr,
  sqlite,
  zeromq,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "dumpvdl2";
  version = "2.4.0";

  src = fetchFromGitHub {
    owner = "szpajder";
    repo = "dumpvdl2";
    tag = "v${finalAttrs.version}";
    hash = "sha256-kb8FLVuG9tSZta8nmaKRCRZinF1yy4+NNxD5s7X82Wk=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    glib
    libacars
    protobufc
    rtl-sdr
    soapysdr
    sqlite
    zeromq
  ];

  meta = {
    description = "VDL Mode 2 message decoder and protocol analyzer";
    homepage = "https://github.com/szpajder/dumpvdl2";
    license = lib.licenses.gpl3Plus;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.unix;
  };
})
