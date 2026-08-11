{ lib
, stdenv
, fetchFromGitHub
, flex
, bison
#, pkg-config
, ncurses
}:

stdenv.mkDerivation rec {
  pname = "kconfig";
  version = "6.1";

  src = fetchFromGitHub {
    owner = "WangNan0";
    repo = "kbuild-standalone";
    rev = "v${version}";
    hash = "sha256-myqdokeHLE3AEePEXCE0Q4NCCNWFiMgVYJPP2btwNz8=";
  };

  nativeBuildInputs = [
    flex
    bison
    #pkg-config # called but not needed
  ];

  buildInputs = [
    ncurses
  ];

  buildPhase = ''
    patchShebangs .
    mkdir build
    cd build
    make -C ../ -f Makefile.sample O=$PWD -j
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp kconfig/*conf $out/bin
  '';

  meta = with lib; {
    description = "Standalone kconfig, extracted from the Linux kernel";
    homepage = "https://github.com/WangNan0/kbuild-standalone";
    license = licenses.gpl2Only;
    maintainers = with maintainers; [ ];
    mainProgram = "kconfig";
    platforms = platforms.all;
  };
}
