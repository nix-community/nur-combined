{ clangStdenv, lib, fetchurl, unzip }:

clangStdenv.mkDerivation {
  name = "PractRand";
  src = fetchurl {
    url = "https://downloads.sourceforge.net/project/pracrand/PractRand_0.93.zip";
    sha256 = "18s65qy2j0p6n5fw5qk84qnrdg0ckchy2ah7bx05w8iyzsyl40bn";
  };
  nativeBuildInputs = [ unzip ];

  unpackPhase = ''
    unzip -q $src
  '';
  patchPhase = ''
    patch -p1 < ${./practrand-0.93-memset.patch}
    patch -p0 < ${./practrand-0.93-bigbuffer.patch}
  '';
  buildPhase = ''
    clang++ -Wno-array-bounds -Wno-parentheses -Wno-constant-logical-operand -std=c++14 -c src/*.cpp src/RNGs/*.cpp src/RNGs/other/*.cpp -O3 -Iinclude -pthread
    ar rcs libPractRand.a *.o
    rm *.o
    clang++ -Wno-array-bounds -Wno-parentheses -Wno-constant-logical-operand -std=c++14 -o RNG_test tools/RNG_test.cpp libPractRand.a -O3 -Iinclude -pthread
  '';
  installPhase = ''
    mkdir -p $out/bin
    cp RNG_test $out/bin
  '';

  meta = with lib; {
    description = "C++ library of pseudo-random number generators and statistical tests for RNGs.";
    license = licenses.publicDomain;
    homepage = http://pracrand.sourceforge.net/;
    maintainers = [ maintainers.idontgetoutmuch ];
  };
}
