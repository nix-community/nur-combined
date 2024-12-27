{ lib, stdenv, fetchpatch, fetchFromGitHub }:

stdenv.mkDerivation rec {
  pname = "ctrtool";
  version = "makerom-v0.18.4-unstable-2024-07-20";

  src = fetchFromGitHub {
    owner = "3DSGuy";
    repo = "Project_CTR";
    rev = "6337c49a15cc7fcee9a3c9e44758dbce2393b26e";
    sha256 = "sha256-wjU/DJHrAHE3MSB7vy+swUDVPzw0Jrv4ymOjhfr0BBk=";
  };

  patches = [
    (fetchpatch {
      url = "https://github.com/3DSGuy/Project_CTR/pull/154.patch";
      hash = "sha256-jgNWxsqYJZ+aTno6cCOHhYaZ0lhFl3OxwKbVtNRB9dE=";
    })
  ];

  preBuild = ''
    cd ctrtool
    make -j$NIX_BUILD_CORES deps CC=${stdenv.cc.targetPrefix}cc CXX=${stdenv.cc.targetPrefix}c++
  '';
  makeFlags = [ "CC=${stdenv.cc.targetPrefix}cc" "CXX=${stdenv.cc.targetPrefix}c++" ];
  enableParallelBuilding = true;

  installPhase = ''
    mkdir $out/bin -p
    cp bin/ctrtool $out/bin/
  '';

  meta = with lib; {
    license = licenses.mit;
    description = "A tool to extract data from a 3ds rom (latest commits)";
    homepage = "https://github.com/3DSGuy/Project_CTR";
    platforms = platforms.all;
    mainProgram = "ctrtool";
  };

}
