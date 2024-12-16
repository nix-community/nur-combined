{ lib, libiconv, stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  pname = "makerom";
  version = "0.18.4";

  src = fetchFromGitHub {
    owner = "3DSGuy";
    repo = "Project_CTR";
    rev = "makerom-v${version}";
    sha256 = "sha256-XGktRr/PY8LItXsN1sTJNKcPIfnTnAUQHx7Om/bniXg=";
  };

  buildInputs = [ libiconv ];
  sourceRoot = "source/makerom";

  preBuild = ''
    make -j$NIX_BUILD_CORES deps CC=${stdenv.cc.targetPrefix}cc CXX=${stdenv.cc.targetPrefix}c++
  '';
  makeFlags = [ "CC=${stdenv.cc.targetPrefix}cc" "CXX=${stdenv.cc.targetPrefix}c++" ];
  enableParallelBuilding = true;

  installPhase = ''
    mkdir $out/bin -p
    cp bin/makerom $out/bin/
  '';

  meta = with lib; {
    license = licenses.mit;
    description = "make 3ds roms";
    homepage = "https://github.com/3DSGuy/Project_CTR";
    platforms = platforms.all;
    mainProgram = "ctrtool";
  };
}
