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
  darwin,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "dumpvdl2";
  version = "2.3.0";

  src = fetchFromGitHub {
    owner = "szpajder";
    repo = "dumpvdl2";
    rev = "v${finalAttrs.version}";
    hash = "sha256-lmjVLHFLa819sgZ0NfSyKywEwS6pQxzdOj4y8RwRu/8=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs =
    [
      glib
      libacars
      protobufc
      rtl-sdr
      soapysdr
      sqlite
      zeromq
    ]
    ++ lib.optionals stdenv.isDarwin [
      darwin.apple_sdk.frameworks.AppKit
      darwin.apple_sdk.frameworks.Foundation
    ];

  meta = {
    description = "VDL Mode 2 message decoder and protocol analyzer";
    homepage = "https://github.com/szpajder/dumpvdl2";
    license = lib.licenses.gpl3Plus;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.unix;
  };
})
