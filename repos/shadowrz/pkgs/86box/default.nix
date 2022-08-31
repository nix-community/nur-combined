{ lib
, mkDerivation
, fetchFromGitHub
, cmake
, pkg-config
, freetype
, libpng
, rtmidi
, SDL2
, libslirp
, glib
, openal
, qttools
}:

mkDerivation rec {
  pname = "86box";
  version = "3.7.1";

  src = fetchFromGitHub {
    owner = "86Box";
    repo = "86Box";
    rev = "v${version}";
    sha256 = "sha256-Ld9F6C1ioDH4EC3Tl8P86a47FailjLZOCZMbiPrtNjQ=";
  };

  nativeBuildInputs = [ cmake pkg-config qttools ];

  buildInputs = [ freetype libpng rtmidi SDL2 libslirp glib openal ];

  extraCmakeFlags = [ "-DSLIRP_EXTERNAL=ON" ];

  meta = with lib; {
    description = "Emulator of x86-based machines based on PCem";
    homepage = "https://86box.net";
    license = licenses.gpl2Plus;
  };
}
