{ lib
, llvmPackages
, s2e
, cmake
, pkg-config
, glib
, pcre2
, boost
, libq
, libtcg
, capstone
}:

llvmPackages.stdenv.mkDerivation rec {
  pname = "s2e-libcpu";
  inherit (s2e) version src;

  patchPhase = ''
    # note: stay in this directory for build
    cd libcpu

    substituteInPlace CMakeLists.txt \
      --replace-fail 'find_package(LIBQ REQUIRED)' "$(
        echo 'set(LIBQ_PACKAGE_VERSION "${libq.version}")'
        echo 'set(LIBQ_INCLUDE_DIR "${libq}/include")'
        echo 'set(LIBQ_LIBRARY_DIR "${libq}/lib")'
        echo 'message(STATUS "Using LIBQ_LIBRARY_DIR ''${LIBQ_LIBRARY_DIR}")'
      )" \
      --replace-fail 'find_package(LIBTCG REQUIRED)' "$(
        echo 'set(LIBTCG_PACKAGE_VERSION "${libtcg.version}")'
        echo 'set(LIBTCG_INCLUDE_DIR "${libtcg}/include")'
        echo 'set(LIBTCG_LIBRARY_DIR "${libtcg}/lib")'
        echo 'message(STATUS "Using LIBTCG_LIBRARY_DIR ''${LIBTCG_LIBRARY_DIR}")'
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
    libq
    libtcg
    # fix: /build/source/libcpu/src/disas.c:26:10: fatal error: 'capstone/capstone.h' file not found
    capstone
  ];

  propagatedBuildInputs = [
    boost
  ];

  # TODO which one? target? host? guest?
  cmakeFlags = [
    "-DWITH_TARGET=${llvmPackages.stdenv.targetPlatform.system}"
  ];

  installPhase = ''
    mkdir -p $out/lib
    cp src/libcpu.a $out/lib
    cp -r ../include $out
    # include/cpu/config-host.h
    # include/cpu/config-target.h
    cp include/cpu/*.h $out/include/cpu
  '';
}
