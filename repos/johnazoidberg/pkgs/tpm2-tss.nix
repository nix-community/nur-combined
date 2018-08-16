{ lib, stdenv, fetchurl, pkgconfig, libgcrypt, doxygen, file, perl }:

stdenv.mkDerivation rec {
  name = "tpm-tss-${version}";
  version = "2.0.1";

  src = fetchurl {
    url = "https://github.com/tpm2-software/tpm2-tss/releases/download/${version}/tpm2-tss-${version}.tar.gz";
    sha256 = "1rb0n8b0b0a45956s68qw8ciyb20lc1agc60s23hv8bm8chjafx5";
  };

  buildInputs = [
    pkgconfig
    libgcrypt
    doxygen perl
  ];

  preConfigure = ''
    substituteInPlace configure --replace "/usr/bin/file" "${file}/bin/file"
  '';

  meta = {
    homepage = https://github.com/tpm2-software/tpm2-tss;
    description = "OSS implementation of the TCG TPM2 Software Stack (TSS2)";
    license = lib.licenses.bsd2;
    platforms = lib.platforms.linux;
    maintainers = [ lib.maintainers.johnazoidberg ];
  };
}
