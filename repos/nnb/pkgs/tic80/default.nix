{ stdenv, lib, fetchzip, cmake, rake, libGLU, freeglut, libglvnd, SDL2 }:

stdenv.mkDerivation rec {
  name = "tic80-${version}";
  version = "0.90.1723";

  src = fetchzip {
    url = "https://github.com/nesbox/TIC-80/archive/refs/tags/v${version}.zip";
    sha256 = "0anfg24whrmjgfh24akc6i78gbm4fg8rq55nyni4qahp8adysxq3";
  };

  nativeBuildInputs = [ cmake ];
  buildInputs = [ rake libGLU freeglut libglvnd SDL2 ];

  installPhase = ''
    cd build

    cmake -DBUILD_PRO=true ..
    make -j4

    install -Dm755 bin/tic80 $out/bin/tic80
    install -Dm755 bin/player-sdl $out/bin/player-sdl
    install -Dm755 bin/bin2txt $out/bin/bin2txt
    install -Dm644 linux/tic80.desktop -t $out/share/applications/
    install -Dm644 linux/tic80.png -t $out/share/icons/
  '';

  meta = with lib; {
    homepage = "https://tic80.com";
    description = "TIC-80 is a fantasy computer for making, playing and sharing tiny games";
    license = licenses.mit;
  };
}
