{
  lib,
  stdenv,
  callPackage,
  fetchFromGitHub,
  libtool,
  autoconf,
  automake,
  pkg-config,
  libusb1,
  libxml2,
}:

let
  gettext = callPackage ./gettext-0.22.5/package.nix { };
in
stdenv.mkDerivation rec {
  pname = "vitamtp";
  version = "2.5.9";

  src = fetchFromGitHub {
    owner = "codestation";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-yKlfy+beEd0uxfWvMCA0kUGhj8lkuQztdSz6i99xiSU=";
  };

  preConfigure = ''
    ./autogen.sh
  '';

  buildInputs = [
    gettext
    libusb1
    libxml2
  ];
  nativeBuildInputs = [
    libtool
    autoconf
    automake
    pkg-config
  ];
}
