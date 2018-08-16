{ lib, stdenv, fetchFromGitHub, gcc-arm-embedded, python }:
stdenv.mkDerivation rec {
  name = "libopencm-${version}";
  version = "2017-04-01";

  src = fetchFromGitHub {
    owner = "libopencm3";
    repo = "libopencm3";
    rev = "383fafc862c0d47f30965f00409d03a328049278";
    sha256 = "0ar67icxl39cf7yb5glx3zd5413vcs7zp1jq0gzv1napvmrv3jv9";
  };

  buildInputs = [ gcc-arm-embedded python ];
  buildPhase = ''
    sed -i 's#/usr/bin/env python#${python}/bin/python#' ./scripts/irq2nvic_h
    make
  '';
  installPhase = ''
    mkdir -p $out
    cp -r lib $out/
  '';

  meta = {
    description = "Open Source ARM cortex m microcontroller library";
    homepage = https://github.com/libopencm3/libopencm3;
    license = stdenv.lib.licenses.gpl2;
    platforms = stdenv.lib.platforms.linux;
    maintainers = with stdenv.lib.maintainers; [ makefu ];
  };
}
