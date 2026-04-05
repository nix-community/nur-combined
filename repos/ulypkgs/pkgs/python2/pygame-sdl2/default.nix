{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  isPy27,
  cython,
  SDL2,
  SDL2_image,
  SDL2_ttf,
  SDL2_mixer,
  libjpeg,
  libpng,
}:

buildPythonPackage rec {
  pname = "pygame_sdl2";
  version = "7.8.7.25031702";

  src = fetchFromGitHub {
    owner = "renpy";
    repo = "pygame_sdl2";
    tag = "renpy-${version}";
    hash = "sha256-7MoQpCkBd20qck7eycs/MX0sjj4XRIrZmYPkKhuct6w=";
  };

  nativeBuildInputs = [
    SDL2.dev
    cython
  ];

  buildInputs = [
    SDL2
    SDL2_image
    SDL2_ttf
    SDL2_mixer
    libjpeg
    libpng
  ];

  doCheck = isPy27; # python3 tests are non-functional

  postInstall = ''
    ( cd "$out"/include/python*/ ;
      ln -s pygame-sdl2 pygame_sdl2 || true ; )
  '';

  meta = with lib; {
    description = "A reimplementation of parts of pygame API using SDL2";
    homepage = "https://github.com/renpy/pygame_sdl2";
    # Some parts are also available under Zlib License
    license = licenses.lgpl2;
    maintainers = with maintainers; [ raskin ];
  };
}
