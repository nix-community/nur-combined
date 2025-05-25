{ lib, stdenv, fetchFromGitHub, premake5, glfw, openal, libX11, libXrandr, mpg123, libsndfile }:

stdenv.mkDerivation rec {
  pname = "re3";
  version = "0.1";

  src = fetchFromGitHub {
    owner = "halpz";
    repo = "re3";
    rev = "310dd8637147c4db643107b69d603902abc78141";
    sha256 = "sha256-/6VRXYT0fA7PitwK4GecpHPQiuLjDpMURfGUmjz8r0k=";
    fetchSubmodules = true;
  };

  buildInputs = [ glfw openal mpg123 libsndfile ];
  nativeBuildInputs = [ premake5 ];

  preConfigure = ''
    patchShebangs printHash.sh
  '';

  buildPhase = ''
    premake5 --with-librw gmake2
    cd build
    make config=release_linux-amd64-librw_gl3_glfw-oal
  '';

  installPhase = ''
    install -Dm755 ../bin/linux-amd64-librw_gl3_glfw-oal/Release/re3 $out/bin/re3
    mkdir -p $out/share/games/re3
    cp -r ../gamefiles $out/share/games/re3
  '';
  meta = with lib; {
    description = "GTA III engine";
    license = licenses.unfree;
    homepage = src.meta.homepage;
    platforms = platforms.linux;
    maintainers = with maintainers; [ ];
  };
}
