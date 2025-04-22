{ lib
, stdenv
, fetchFromGitHub
, pkg-config
, zlib
, poppler_utils
, avahi
, pdfio
, darwin
}:

stdenv.mkDerivation rec {
  pname = "libcups";
  #version = "3.0b2";
  version = "3.0b2-unstable-2024-08-14";

  src = fetchFromGitHub {
    owner = "OpenPrinting";
    repo = "libcups";
    #rev = "v${version}";
    # fix: install: ipp-2.1.test does not exist
    # https://github.com/OpenPrinting/libcups/issues/85
    rev = "7a8ff5880e878c10e2604c1a59897f8f77ff2d80";
    hash = "sha256-qQB4UA9pxLSmCTOH8PLTILksTfA53VGLg70DpIj0+/8=";
  };

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    poppler_utils # pdftoppm
    avahi
    zlib
    pdfio
  ]
  ++ lib.optionals stdenv.isDarwin [
    darwin.apple_sdk.frameworks.CoreFoundation
  ];

  meta = with lib; {
    description = "OpenPrinting CUPS library and tools: ippevepcl ippeveprinter ippeveps ippfind ipptool ipptransform";
    homepage = "https://github.com/OpenPrinting/libcups";
    changelog = "https://github.com/OpenPrinting/libcups/blob/${src.rev}/CHANGES.md";
    license = licenses.asl20;
    maintainers = with maintainers; [ ];
    mainProgram = "ipptool";
    platforms = platforms.all;
  };
}
