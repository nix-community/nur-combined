{ stdenv, fetchFromGitHub, cmake, llvm, libxml2, libuuid }:

stdenv.mkDerivation {
  name = "libEBC";
  version = "2017-08-30";

  src = fetchFromGitHub {
    owner = "JDevlieghere";
    repo = "LibEBC";
    rev = "8f89102e9d15f6b065d25cebf3f77204b359df2a";
    sha256 = "0iv5zs460xgm6hfixs65dy53ysiqva24ri9hxrxglsg94lwsj0fx";
  };

  nativeBuildInputs = [ cmake ];
  buildInputs = [ llvm libxml2 libuuid ];

  cmakeFlags = [
    "-DBUILD_SHARED_LIBS=ON"
  ];

  doCheck = true;

  checkPhase = ''
    LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$PWD/lib ./test/ebctest
  '';

  installPhase = ''
    install -D -t $out/bin tool/ebcutil

    install -D -t $out/lib lib/libebc.so
    install -D -t $out/include/ebc ../lib/include/ebc/*.h
    install -D -t $out/include/ebc/tuil ../lib/include/ebc/util/*.h
  '';

  meta = with stdenv.lib; {
    description = "C++ Library and Tool for Extracting Embedded Bitcode";
    homepage = https://jdevlieghere.github.io/LibEBC;
    license = licenses.asl20;
  };
}

