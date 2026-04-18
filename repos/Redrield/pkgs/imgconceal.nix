{ stdenv, stdenvAdapters, fetchFromGitHub, glibc, libsodium, libjpeg, libpng, libwebp, zlib, lib }:
stdenv.mkDerivation rec {
  pname = "imgconceal";
  version = "1.0.4";

  src = fetchFromGitHub {
    owner = "tbpaolini";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-5Adq5U7m73W14y0lcOSOzLURFbdZBWJuMtqVFfZwCx0=";
  };

  buildInputs = [
    (stdenvAdapters.makeStatic libsodium)
    libjpeg
    libpng
    libwebp
    zlib
    stdenv.cc.cc.lib
  ];
}
