{ lib
, llvmPackages
, s2e
, cmake
, pkg-config
, glib
, pcre2
, libxml2
, boost
, capstone
, libq
, libtcg
, libcpu
, libfsigcxx
, klee
}:

llvmPackages.stdenv.mkDerivation rec {
  pname = "s2e-libs2ecore";
  inherit (s2e) version src;

  patchPhase = ''
    # note: stay in this directory for build
    cd libs2ecore

    substituteInPlace CMakeLists.txt \
      --replace-fail 'find_package(LIBQ REQUIRED)' "$(
        echo 'set(LIBQ_PACKAGE_VERSION "${libq.version}")'
        echo 'set(LIBQ_INCLUDE_DIR "${libq}/include")'
        echo 'set(LIBQ_LIBRARY_DIR "${libq}/lib")'
        echo 'message(STATUS "Using LIBQ_INCLUDE_DIR ''${LIBQ_INCLUDE_DIR}")'
        echo 'message(STATUS "Using LIBQ_LIBRARY_DIR ''${LIBQ_LIBRARY_DIR}")'
      )" \
      --replace-fail 'find_package(LIBCPU REQUIRED)' "$(
        echo 'set(LIBCPU_PACKAGE_VERSION "${libcpu.version}")'
        echo 'set(LIBCPU_INCLUDE_DIR "${libcpu}/include")'
        echo 'set(LIBCPU_LIBRARY_DIR "${libcpu}/lib")'
        echo 'message(STATUS "Using LIBCPU_INCLUDE_DIR ''${LIBCPU_INCLUDE_DIR}")'
        echo 'message(STATUS "Using LIBCPU_LIBRARY_DIR ''${LIBCPU_LIBRARY_DIR}")'
      )" \
      --replace-fail 'find_package(LIBTCG REQUIRED)' "$(
        echo 'set(LIBTCG_PACKAGE_VERSION "${libtcg.version}")'
        echo 'set(LIBTCG_INCLUDE_DIR "${libtcg}/include")'
        echo 'set(LIBTCG_LIBRARY_DIR "${libtcg}/lib")'
        echo 'message(STATUS "Using LIBTCG_INCLUDE_DIR ''${LIBTCG_INCLUDE_DIR}")'
        echo 'message(STATUS "Using LIBTCG_LIBRARY_DIR ''${LIBTCG_LIBRARY_DIR}")'
      )" \
      --replace-fail 'find_package(FSIGCXX REQUIRED)' "$(
        echo 'set(FSIGCXX_PACKAGE_VERSION "${libfsigcxx.version}")'
        echo 'set(FSIGCXX_INCLUDE_DIR "${libfsigcxx}/include")'
        echo 'set(FSIGCXX_LIBRARY_DIR "${libfsigcxx}/lib")'
        echo 'message(STATUS "Using FSIGCXX_INCLUDE_DIR ''${FSIGCXX_INCLUDE_DIR}")'
        echo 'message(STATUS "Using FSIGCXX_LIBRARY_DIR ''${FSIGCXX_LIBRARY_DIR}")'
      )" \
      --replace-fail 'find_package(KLEE REQUIRED)' "$(
        echo 'set(KLEE_PACKAGE_VERSION "${klee.version}")'
        echo 'set(KLEE_INCLUDE_DIR "${klee}/include")'
        echo 'set(KLEE_LIBRARY_DIR "${klee}/lib")'
        echo 'message(STATUS "Using KLEE_INCLUDE_DIR ''${KLEE_INCLUDE_DIR}")'
        echo 'message(STATUS "Using KLEE_LIBRARY_DIR ''${KLEE_LIBRARY_DIR}")'
      )" \
  '';

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    #boost
    glib
    pcre2 # for glib
    libxml2
    llvmPackages.libllvm
  ];

  propagatedBuildInputs = [
    #boost
  ];

  # TODO remove? s2e/libs2e/CMakeLists.txt searches for "s2e" in WITH_TARGET
  # TODO which one? target? host? guest?
  cmakeFlags = [
    #"-DWITH_TARGET=${llvmPackages.stdenv.targetPlatform.system}"
  ];

  installPhase = ''
    mkdir -p $out/lib
    set -x
    echo TODO install lib and headers
    find . -name '*.a' -or -name '*.so'
    cp src/libs2ecore.a $out/lib
    cp -r ../include $out
    ls
    ls include/ || true
    set +x
  '';
}
