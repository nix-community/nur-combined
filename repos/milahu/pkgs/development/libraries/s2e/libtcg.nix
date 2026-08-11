{ lib
, llvmPackages
, s2e
, cmake
, pkg-config
, libq
, glib
, pcre2
, boost
, libxml2
, libbsd
}:

llvmPackages.stdenv.mkDerivation rec {
  pname = "s2e-libtcg";
  inherit (s2e) version src;

  patchPhase = ''
    # note: stay in this directory for build
    cd libtcg

    substituteInPlace CMakeLists.txt \
      --replace-fail 'find_package(LIBQ REQUIRED)' "$(
        echo 'set(LIBQ_PACKAGE_VERSION "${libq.version}")'
        echo 'set(LIBQ_INCLUDE_DIR "${libq}/include")'
        echo 'set(LIBQ_LIBRARY_DIR "${libq}/lib")'
        echo 'message(STATUS "Using LIBQ_LIBRARY_DIR ''${LIBQ_LIBRARY_DIR}")'
      )" \

  '';

  nativeBuildInputs = [
    cmake
  ];

  buildInputs = [
    #boost
    pkg-config
    glib
    pcre2
    libq # qqueue.h
    llvmPackages.llvm
    libxml2
    libbsd # bsd/string.h
  ];

  propagatedBuildInputs = [
    boost
  ];

  # TODO which one? target? host? guest?
  cmakeFlags = [
    "-DWITH_GUEST=${llvmPackages.stdenv.targetPlatform.system}"
  ];

  installPhase = ''
    mkdir -p $out/lib
    cp src/libtcg.a $out/lib
    cp -r ../include $out
  '';
}
