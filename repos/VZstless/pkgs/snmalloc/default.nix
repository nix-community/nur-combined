{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "snmalloc";
  version = "0.7.3";
  src = fetchFromGitHub {
    owner = "microsoft";
    repo = "snmalloc";
    rev = finalAttrs.version;
    sha256 = "sha256-G3bIH50HVfRqJaSEHSE3elAAlWAQmS0lvnVq8g42yxw=";
  };

  nativeBuildInputs = [ 
    cmake 
    pkg-config 
  ];

  cmakeFlags = [
    "-DCMAKE_CXX_FLAGS=-Wno-error=use-after-free"
  ];

  meta = {
    description = "Message passing based memory allocator";
    homepage = "https://github.com/microsoft/snmalloc";
    license = lib.licenses.mit;
    platforms = lib.platforms.unix;
  };
})
