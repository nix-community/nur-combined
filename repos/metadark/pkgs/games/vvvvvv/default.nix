{ stdenv, fetchFromGitHub
, cmake, SDL2, SDL2_mixer
, Foundation
}:

stdenv.mkDerivation rec {
  pname = "vvvvvv";
  version = "f4767ce18ba12231084b0ba592ad061cf301f1ed";

  src = fetchFromGitHub {
    owner = "TerryCavanagh";
    repo = pname;
    rev = version;
    sha256 = "14wvbvbardzxvdyl0z2mg72a9mgbmw542jn4mk7fxmnpsx8171a0";
  };

  sourceRoot = "source/desktop_version";
  patches = [
    ./no-executable-suffix.patch
  ];

  nativeBuildInputs = [ cmake ];
  buildInputs = [
    SDL2 SDL2_mixer
  ] ++ stdenv.lib.optionals stdenv.isDarwin [
    Foundation
  ];

  installPhase = ''
    mkdir -p "$out/bin"
    cp vvvvvv "$out/bin"
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
