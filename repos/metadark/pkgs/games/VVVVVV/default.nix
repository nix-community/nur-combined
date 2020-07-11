{ stdenv, fetchFromGitHub
, cmake, SDL2, SDL2_mixer
, Foundation
}:

stdenv.mkDerivation rec {
  pname = "VVVVVV-unwrapped";
  version = "15319b9";

  src = fetchFromGitHub {
    owner = "TerryCavanagh";
    repo = "VVVVVV";
    rev = version;
    sha256 = "03aibc5navdfvsxrc272fb8xjhk1bd22jjglq4pswiwpza0fxj7q";
  };

  sourceRoot = "source/desktop_version";

  nativeBuildInputs = [ cmake ];
  buildInputs = [
    SDL2 SDL2_mixer
  ] ++ stdenv.lib.optionals stdenv.isDarwin [
    Foundation
  ];

  patchFlags = [ "-p2" ];
  patches = [
    ./find-sdl-mixer.patch
  ];

  installPhase = ''
    mkdir -p "$out/bin"
    cp VVVVVV "$out/bin"
  '';

  meta = with stdenv.lib; {
    description = "A retro-styled 2D platformer";
    homepage = "https://thelettervsixtim.es";
    license = {
      fullName = "VVVVVV Source Code License v1.0";
      url = "https://github.com/TerryCavanagh/VVVVVV/blob/master/LICENSE.md";
      free = false;
      redistributable = true;
    };
    maintainers = with maintainers; [ metadark ];
    platforms = platforms.all;
  };
}
