{ lib
, llvmPackages
, s2e
, cmake
, boost
}:

llvmPackages.stdenv.mkDerivation rec {
  pname = "s2e-libfsigcxx";
  inherit (s2e) version src;

  patchPhase = ''
    # note: stay in this directory for build
    cd libfsigc++
  '';

  nativeBuildInputs = [
    cmake
  ];

  buildInputs = [
    # fix: /build/source/libfsigc++/include/fsigc++/fsigc++.h:27:10: fatal error: 'boost/container/small_vector.hpp' file not found
    boost
  ];

  propagatedBuildInputs = [
    boost
  ];

  # TODO dont build: sigtest

  installPhase = ''
    mkdir -p $out/lib
    cp src/libfsigc++.a $out/lib
    cp -r ../include $out
  '';
}
