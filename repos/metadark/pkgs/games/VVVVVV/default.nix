{ stdenv, fetchFromGitHub
, cmake, SDL2, SDL2_mixer
, Foundation
}:

stdenv.mkDerivation rec {
  pname = "VVVVVV-unwrapped";
  version = "d4034661e260ee3eda610a21db75b9695cd4a0ad";

  src = fetchFromGitHub {
    owner = "TerryCavanagh";
    repo = pname;
    rev = version;
    sha256 = "0kfnvfs5bi0iwjfq99wci91k89l8qgvmwxf896rinawcdxad6025";
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
