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
  version = "3.11";

  src = fetchFromGitHub {
    owner = "86Box";
    repo = "86Box";
    rev = "v${version}";
    sha256 = "sha256-n3Q/NUiaC6/EZyBUn6jUomnQCqr8tvYKPI5JrRRFScI=";
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
