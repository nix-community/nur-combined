{
  lib,
  stdenv,
  fetchurl,
  gcc11,
  cmake,
  pkgconf,
  bison,
  flex,
  openssl,
  libusb1,
  json_c,
  hidapi,
}:

let
  openssl-static = openssl.override {
    static = true;
  };
  libusb1-static = libusb1.override { withStatic = true; };
  hidapi-static = hidapi.overrideAttrs (oldAttrs: {
    cmakeFlags = (oldAttrs.cmakeFlags or [ ]) ++ [
      "-DBUILD_SHARED_LIBS=OFF"
    ];
  });
in
stdenv.mkDerivation {
  pname = "cst";
  version = "4.0.0";

  # Old CST version original link: https://www.nxp.com/webapp/sps/download/license.jsp?colCode=IMX_CST_TOOL
  # New CST version original link: https://www.nxp.com/webapp/sps/download/license.jsp?colCode=IMX_CST_TOOL_NEW
  #
  # Some versions (3.3.0, 3.3.1, 3.3.2, 3.4.1) can be found here:
  # - https://packages.debian.org/sid/imx-code-signing-tool
  # - https://ftp1.digi.com/support/digiembeddedyocto/source
  # - https://gitlab.apertis.org/pkg/imx-code-signing-tool
  #
  # Original SHA256:
  # - cst-3.1.0.tgz: a8cb42c99e9bacb216a5b5e3b339df20d4c5612955e0c353e20f1bb7466cf222
  # - cst-3.3.2.tgz: 517b11dca181e8c438a6249f56f0a13a0eb251b30e690760be3bf6191ee06c68
  # - cst-4.0.0.tgz: 8533b5a32400674d7c44edbd5cb032c2c64e6442da73c9bd04788429161071af
  # - cst-4.0.1.tgz: 60ffc243daa5e4e2ccfac8a9b74aec6d21446122a453fcb896dc52881d2a779d
  src = fetchurl {
    url = "http://github.com/compulab-yokneam/cst-tools/raw/ac2a63da087c6e9e5b02d3fe19d615d7c19f929f/nxp/cst-4.0.0.tgz";
    hash = "sha256-hTO1oyQAZ018RO29XLAywsZOZELac8m9BHiEKRYQca8=";
  };

  patches = [
    ./0001-fix-build-error-with-some-gcc-version.patch
  ];

  nativeBuildInputs = [
    gcc11
    cmake
    pkgconf
    bison
    flex
    openssl-static
    libusb1-static
    json_c
    hidapi-static
  ];

  cmakeDir = "../src";

  meta = {
    description = "Code Signing Tool for i.MX platform";
    homepage = "https://www.nxp.com";
    mainProgram = "cst";
    license = lib.licenses.unfree;
    platforms = [
      "x86_64-linux"
      "i686-linux"
    ];
  };
}
