{ lib, stdenv, fetchurl, fetchgit, premake5, glfw, openal, mpg123, libsndfile }:

stdenv.mkDerivation rec {
  pname = "re3";
  version = "0.1";

  src' = fetchurl {
    url = "https://archive.org/download/github.com-GTAmodding-re3_-_2021-09-06_14-11-00/GTAmodding-re3_-_2021-09-06_14-11-00.bundle";
    sha256 = "sha256-A1y19ZgRrghlEPAr04F+r0OTPJcj5S26YIB/SMTp2cM=";
  };

  src = fetchgit {
    url = src';
    sha256 = "sha256-WCvs5QGkfnj33yu26LdSVTtwhuLyB3NhkT1i1nirvCk=";
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
    homepage = "https://archive.org/details/github.com-GTAmodding-re3_-_2021-09-06_14-11-00";
    platforms = platforms.linux;
    maintainers = with maintainers; [ ];
  };
}
