# WONTFIX s2e-klee fails to compile with llvmPackages_11

{ lib
, callPackage
, stdenv
, llvmPackages
, llvmPackages_6
, llvmPackages_7
, llvmPackages_8
, llvmPackages_9
, llvmPackages_10
, llvmPackages_11
, llvmPackages_12
, fetchFromGitHub
, cmake
, pkg-config
, capstone
, z3
, lua
, soci
#, googletest # missing https://github.com/google/googletest
, libdwarf
, rapidjson
, libxml2
, libffi
, libelf
, zstd
#, klee
, glib
, pcre2 # required by glib
, protobuf
}:

let
  libvmi = callPackage ./libvmi.nix { };
  libfsigcxx = callPackage ./libfsigcxx.nix { };
  libcoroutine = callPackage ./libcoroutine.nix { };
  libq = callPackage ./libq.nix { };
  libtcg = callPackage ./libtcg.nix {
    inherit libq;
  };
  libcpu = callPackage ./libcpu.nix {
    inherit libq libtcg;
  };
  libs2ecore = callPackage ./libs2ecore.nix {
    inherit libq libtcg libcpu libfsigcxx klee;
  };
  # old klee version from 2009
  klee = callPackage ./klee.nix {
    # WONTFIX s2e-klee fails to compile with llvmPackages_11
    llvmPackages = llvmPackages_11;
  };
in

llvmPackages.stdenv.mkDerivation rec {
  pname = "libs2e";
  #version = "2.0.0"; # old: 2020-01-18
  version = "unstable-2024-04-13-broken";

  src = fetchFromGitHub {
    owner = "S2E";
    repo = "s2e";
    rev = "5814e5a39b2718e4839b06d5d70297e74c4b95f5";
    hash = "sha256-5zS2mB8cX45DdAaPFfsRUHwB//zOKMEDHjgfT9Qxq0A=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  passthru = {
    inherit
      libvmi
      libfsigcxx
      libcoroutine
      libq
      libtcg
      libcpu
      libs2ecore
      klee
    ;
  };

  buildInputs = [
    libvmi
    libfsigcxx
    libcoroutine
    libq
    libtcg
    libcpu
    libs2ecore
    klee

    llvmPackages.libllvm
    capstone
    z3
    lua
    soci # https://github.com/SOCI/soci
    #googletest
    libdwarf
    rapidjson
    libxml2
    libffi
    # fix: /build/source/libvmi/include/vmi/ELFFile.h:27:10: fatal error: 'libelf.h' file not found
    libelf
    # fix: /nix/store/0gi4vbw1qfjncdl95a9ply43ymd6aprm-binutils-2.40/bin/ld: cannot find -lzstd: No such file or directory
    zstd
    glib
    pcre2 # required by glib
    protobuf
    klee
  ];

  #dontUseCmakeConfigure = true;

  # based on s2e/libs2e/configure
  cmakeFlags = [
    #"-DCMAKE_C_COMPILER=$CC"
    #"-DCMAKE_CXX_COMPILER=$CXX"
    #"-DCMAKE_C_FLAGS=$CFLAGS"
    #"-DCMAKE_CXX_FLAGS=$CXXFLAGS"
    #"-DCMAKE_BUILD_TYPE=$BUILD_TYPE"
    #"-DCMAKE_PREFIX_PATH=$PREFIX"
    "-DLIBTCG_DIR=/build/source/libtcg"
    "-DLIBCPU_DIR=/build/source/libcpu"
    "-DLIBS2ECORE_DIR=/build/source/libs2ecore"
    "-DLIBS2EPLUGINS_DIR=/build/source/libs2eplugins"
    /*
    "-DLIBQ_DIR=${libq}"
    "-DLLVM_DIR=${llvmPackages.libllvm.dev}"
    "-DLIBCOROUTINE_DIR=${libcoroutine}"
    "-DKLEE_DIR=${klee}"
    "-DVMI_DIR=${libvmi}"
    "-DLUA_DIR=${lua}"
    "-DFSIGCXX_DIR=${libfsigcxx}"
    "-DZ3_DIR=${z3.lib}"
    "-DCAPSTONE_LIB_DIR=${capstone}"
    */
    "-DWITH_TARGET=s2e"
  ];

  patchPhase = ''
    # fix: Compatibility with CMake < 3.5 will be removed
    find . -name CMakeLists.txt | xargs sed -i 's/^cmake_minimum_required(.*)$/cmake_minimum_required(VERSION 3.10)/'

    # note: stay in this directory for build
    cd libs2e

    substituteInPlace configure \
      --replace-fail 'libz3.a' 'libz3.so' \
      --replace-fail 'libcapstone.a' 'libcapstone.so' \
      --replace-fail 'LIBCPU_REVISION="$(get_git_revision)"' 'LIBCPU_REVISION="${src.rev}"' \

    substituteInPlace CMakeLists.txt \
      --replace-fail 'find_package(KLEE REQUIRED)' "$(
        echo 'set(KLEE_PACKAGE_VERSION "${klee.version}")'
        echo 'set(KLEE_INCLUDE_DIR "${klee}/include")'
        echo 'set(KLEE_LIBRARY_DIR "${klee}/lib")'
        echo 'message(STATUS "Using KLEE_LIBRARY_DIR ''${KLEE_LIBRARY_DIR}")'
      )" \
      --replace-fail 'find_package(LIBQ REQUIRED)' "$(
        echo 'set(LIBQ_PACKAGE_VERSION "${libq.version}")'
        echo 'set(LIBQ_INCLUDE_DIR "${libq}/include")'
        echo 'set(LIBQ_LIBRARY_DIR "${libq}/lib")'
        echo 'message(STATUS "Using LIBQ_LIBRARY_DIR ''${LIBQ_LIBRARY_DIR}")'
      )" \
      --replace-fail 'find_package(LIBCPU REQUIRED)' "$(
        echo 'set(LIBCPU_PACKAGE_VERSION "${libcpu.version}")'
        echo 'set(LIBCPU_INCLUDE_DIR "${libcpu}/include")'
        echo 'set(LIBCPU_LIBRARY_DIR "${libcpu}/lib")'
        echo 'message(STATUS "Using LIBCPU_LIBRARY_DIR ''${LIBCPU_LIBRARY_DIR}")'
      )" \
      --replace-fail 'find_package(LIBTCG REQUIRED)' "$(
        echo 'set(LIBTCG_PACKAGE_VERSION "${libtcg.version}")'
        echo 'set(LIBTCG_INCLUDE_DIR "${libtcg}/include")'
        echo 'set(LIBTCG_LIBRARY_DIR "${libtcg}/lib")'
        echo 'message(STATUS "Using LIBTCG_LIBRARY_DIR ''${LIBTCG_LIBRARY_DIR}")'
      )" \
      --replace-fail 'find_package(FSIGCXX REQUIRED)' "$(
        echo 'set(FSIGCXX_PACKAGE_VERSION "${libfsigcxx.version}")'
        echo 'set(FSIGCXX_INCLUDE_DIR "${libfsigcxx}/include")'
        echo 'set(FSIGCXX_LIBRARY_DIR "${libfsigcxx}/lib")'
        echo 'message(STATUS "Using FSIGCXX_LIBRARY_DIR ''${FSIGCXX_LIBRARY_DIR}")'
      )" \
      --replace-fail 'find_package(LIBCOROUTINE REQUIRED)' "$(
        echo 'set(LIBCOROUTINE_PACKAGE_VERSION "${libcoroutine.version}")'
        echo 'set(LIBCOROUTINE_INCLUDE_DIR "${libcoroutine}/include")'
        echo 'set(LIBCOROUTINE_LIBRARY_DIR "${libcoroutine}/lib")'
        echo 'message(STATUS "Using LIBCOROUTINE_LIBRARY_DIR ''${LIBCOROUTINE_LIBRARY_DIR}")'
      )" \
      --replace-fail 'find_package(LIBS2ECORE REQUIRED)' "$(
        echo 'set(LIBS2ECORE_PACKAGE_VERSION "${version}")'
        echo 'set(LIBS2ECORE_INCLUDE_DIR "/build/source/libs2ecore/include")'
        echo 'set(LIBS2ECORE_LIBRARY_DIR "/build/source/libs2ecore/lib")'
        echo 'message(STATUS "Using LIBS2ECORE_LIBRARY_DIR ''${LIBS2ECORE_LIBRARY_DIR}")'
      )" \
      --replace-fail 'find_package(LIBS2EPLUGINS REQUIRED)' "$(
        echo 'set(LIBS2EPLUGINS_PACKAGE_VERSION "${version}")'
        echo 'set(LIBS2EPLUGINS_INCLUDE_DIR "/build/source/libs2eplugins/include")'
        echo 'set(LIBS2EPLUGINS_LIBRARY_DIR "/build/source/libs2eplugins/lib")'
        echo 'message(STATUS "Using LIBS2EPLUGINS_LIBRARY_DIR ''${LIBS2EPLUGINS_LIBRARY_DIR}")'
      )" \

  '';

  buildPhase = ''
    set -x
    echo buildPhase
    pwd
    ls
    make
  '';

  meta = with lib; {
    description = "S2E: A platform for multi-path program analysis with selective symbolic execution [BROKEN]";
    homepage = "https://github.com/S2E/s2e";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
    platforms = platforms.all;
  };
}
