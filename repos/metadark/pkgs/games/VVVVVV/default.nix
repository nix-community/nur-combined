{ stdenv
, fetchFromGitHub
, cmake
, SDL2
, SDL2_mixer
, Foundation
}:

let
  executableSuffix =
    if stdenv.isDarwin then ".osx"
    else if stdenv.is64bit then ".x86_64"
    else ".x86";
in
stdenv.mkDerivation rec {
  pname = "VVVVVV-unwrapped";
  version = "2.2";

  src = fetchFromGitHub {
    owner = "TerryCavanagh";
    repo = "VVVVVV";
    rev = version;
    sha256 = "191id9kgivhb54wccfi5bpjnjf7y97w4l832vpf288phjymyl2rj";
  };

  sourceRoot = "source/desktop_version";

  nativeBuildInputs = [ cmake ];
  buildInputs = [
    SDL2
    SDL2_mixer
  ] ++ stdenv.lib.optionals stdenv.isDarwin [
    Foundation
  ];

  patchFlags = [ "-p2" ];
  patches = [
    ./find-sdl-mixer.patch
  ];

  installPhase = ''
    mkdir -p "$out/bin"
    cp vvvvvv${executableSuffix} "$out/bin/VVVVVV"
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
