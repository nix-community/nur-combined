{ stdenv, fetchFromGitHub
, cmake, SDL2, SDL2_mixer
, Foundation
}:

stdenv.mkDerivation rec {
  pname = "VVVVVV-unwrapped";
  version = "68bb84f90b70f70905e054c9f5c033e0049617e4";

  src = fetchFromGitHub {
    owner = "TerryCavanagh";
    repo = "VVVVVV";
    rev = version;
    sha256 = "16qzbgczx9lakbl6fadg4wqgn74mgjwbqaz87p4w8abk2n3vagr5";
  };

  sourceRoot = "source/desktop_version";

  nativeBuildInputs = [ cmake ];
  buildInputs = [
    SDL2 SDL2_mixer
  ] ++ stdenv.lib.optionals stdenv.isDarwin [
    Foundation
  ];

  patches = [
    ./find-sdl-mixer.patch
  ];

  installPhase = ''
    mkdir -p "$out/bin"
    cp VVVVVV "$out/bin"
  '';

  meta = with stdenv.lib; {
    description = "A retro-styled 2D platformer";
    homepage = "https://github.com/TerryCavanagh/VVVVVV";
    license = {
      fullName = "VVVVVV Source Code License v1.0";
      url = "https://github.com/TerryCavanagh/VVVVVV/blob/master/LICENSE.md";
      free = false;
    };
    maintainers = with maintainers; [ metadark ];
    platforms = platforms.all;
  };
}
