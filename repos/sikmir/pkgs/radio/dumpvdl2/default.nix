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
  AppKit,
  Foundation,
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
      AppKit
      Foundation
    ];

  meta = with lib; {
    description = "VDL Mode 2 message decoder and protocol analyzer";
    inherit (finalAttrs.src.meta) homepage;
    license = licenses.gpl3Plus;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
})
