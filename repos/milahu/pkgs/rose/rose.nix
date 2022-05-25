/*
nix-build -E 'with import <nixpkgs> {}; callPackage ./rose.nix {}'

nix-build -E 'with import (builtins.fetchTarball https://github.com/NixOS/nixpkgs/archive/05ced71757730406ca3eb3e58503f05334a6057d.tar.gz) {}; callPackage ./rose.nix {}'
*/

{ lib
, pkgs
, stdenv
, gcc10Stdenv
, fetchFromGitHub
, fetchpatch
, fetchgit
, pkg-config
, fetchurl
, cmake
, boost

# same options as in https://github.com/rose-compiler/rose/blob/weekly/CMakeLists.txt
, enable-c ? true
, enable-clang-frontend ? true
, enable-edg-frontend ? true # closed source
#, enable-cxx ? true # only for configure, not for cmake
, enable-assembly-semantics ? true
, enable-gnu-extensions ? true
, enable-rosehpct ? true
, enable-binary-analysis ? true
, enable-python ? true
, enable-php ? true
, enable-java ? true
, enable-opencl ? true
, with-roseQt ? true

, enable-internalFrontendDevelopment ? false # FIXME true -> configure error https://github.com/rose-compiler/rose/issues/201
, enable-cuda ? false # FIXME cuda-headers are not found by cmake?
, enable-csharp ? false
, enable-fortran ? false
, enable-ada ? false
, enable-jovial ? false
, enable-candl ? false
, enable-cloog ? false
, enable-compass2 ? false
#, enable-edg-cuda ? false
#, enable-edg-opencl ? false
#, enable-edg_union_struct_debugging ? false
, enable-FLTK ? false
, enable-microsoft-extensions ? false
, enable-ppl ? false
, enable-purify-api ? false
, enable-purify-linker ? false
, enable-rose-openGL ? false
, enable-scoplib ? false
, enable-poet ? false
# TODO more options
}:

let
  defaultStdenv = stdenv; # fix infinite recursion
in

let
  # TODO gcc 11 https://github.com/rose-compiler/rose/issues/199
  stdenv = if enable-edg-frontend then gcc10Stdenv else defaultStdenv;
  gccVersion = builtins.elemAt (pkgs.lib.splitVersion stdenv.cc.version) 0; # major version
in

stdenv.mkDerivation rec {
  pname = "rose";
  version = "0.11.82.3"; # latest binary release of EDG

  # https://github.com/rose-compiler/rose/commits/weekly/src/frontend/CxxFrontend/EDG_VERSION
  # find_edg.sh -> find latest binary release of EDG
  src = fetchFromGitHub {
    # https://github.com/rose-compiler/rose/pull/195 # fix cmake
    #owner = "rose-compiler";
    #rev = "v${version}";
    owner = "milahu";
    repo = "rose";
    rev = "patch-1-rebase-to-v0.11.82.3";
    sha256 = "sha256-c86JU6Nr7vFJmUeNEVoZwGfjoGivixQ0arrxutsgpvw="; # todo
    # note: all git submodules are closed source
  };
  #src = ./src/rose-git;

  roseBinaryEDGTarball = if enable-edg-frontend then fetchurl {
    # EDG is closed source -> binary release only
    # https://github.com/rose-compiler/rose/issues/23
    # EDG is currently a hard dependency, also with enable-clang-frontend
    # https://github.com/rose-compiler/rose/issues/26
    url = "http://edg-binaries.rosecompiler.org/roseBinaryEDG-5-0-x86_64-pc-linux-gnu-gnu-${gccVersion}-5.${version}.tar.gz";
    sha256 = "sha256-GOhpDhOkRoOvGnBR5pDmkOyGmjoIyeDM5l2gwkvsSY0="; # gccVersion = "10"; version = "0.11.82.3";
  } else null;

  cmakeFlags = [
    ("-D" + "enable-c=${if enable-c then "ON" else "OFF"}")
    ("-D" + "enable-clang-frontend=${if enable-clang-frontend then "ON" else "OFF"}") # alternative to EDG frontend
    ("-D" + "enable-edg-frontend=${if enable-edg-frontend then "ON" else "OFF"}") # alternative to EDG frontend
    ("-D" + "enable-java=${if enable-java then "ON" else "OFF"}")
    ("-D" + "enable-python=${if enable-python then "ON" else "OFF"}")
    ("-D" + "enable-php=${if enable-php then "ON" else "OFF"}")
    ("-D" + "enable-php=${if enable-php then "ON" else "OFF"}")
    ("-D" + "enable-opencl=${if enable-opencl then "ON" else "OFF"}")
    ("-D" + "enable-binary-analysis=${if enable-binary-analysis then "ON" else "OFF"}")
    ("-D" + "enable-assembly-semantics=${if enable-assembly-semantics then "ON" else "OFF"}")
    ("-D" + "enable-gnu-extensions=${if enable-gnu-extensions then "ON" else "OFF"}")
    ("-D" + "enable-rosehpct=${if enable-rosehpct then "ON" else "OFF"}")
    ("-D" + "enable-internalFrontendDevelopment=${if enable-internalFrontendDevelopment then "ON" else "OFF"}")
    # TODO more options
  ];

  nativeBuildInputs = with pkgs; ([
    cmake
    # using cmake, as configure cannot find boost libraries
    # downside: cmake work-in-progress at upstream -> cmake build system has less options
  ]
  ++ lib.optionals with-roseQt [
    qt5.wrapQtAppsHook
  ]);

  buildInputs = with pkgs; ([
    # autogen.sh
    autoconf
    automake
    which
    libtool

    (boost.override { inherit stdenv; }) # https://github.com/NixOS/nixpkgs/issues/38552
    # FIXME? ANSI C header files - not found
    libmysqlclient
    openssl
    perl
    (z3.override { inherit stdenv; }) # Z3 SMT solver
    capstone
    readline
    #libspot # FIXME SPOT_ROOT in rose
    flex
    bison
    libxml2 # xmllint
    libpng
    pkg-config
    doxygen
    (libyamlcpp.override { inherit stdenv; })
    # libyaml-cpp.so: undefined reference to `std::__throw_bad_array_new_length()@GLIBCXX_3.4.29'
    dlib
    libgcrypt
    #libmagic
    libpqxx
  ]
  ++ lib.optionals with-roseQt [
    qt5.qtbase
  ]
  ++ lib.optionals enable-clang-frontend [
    llvmPackages.libclang
    llvmPackages.llvm
  ]
  ++ lib.optionals enable-java [
    jdk8 # javah
  ]
  ++ lib.optionals enable-opencl [
    opencl-headers
    ocl-icd # libOpenCL.so
  ]);

  dontWrapQtApps = !with-roseQt;

  postPatch = ''
    patchShebangs .
  '';

  # autogen is only needed for EDG (?)
  preConfigure = if enable-edg-frontend then ''
    ./autogen.sh
    mkdir -p build/src/frontend/CxxFrontend
    ln -sv ${roseBinaryEDGTarball} build/src/frontend/CxxFrontend/EDG.tar.gz
  '' else "";

  meta = with lib; {
    description = "compiler infrastructure to build source-to-source program transformation and analysis tools for large-scale C (C89 and C98), C++ (C++98 and C++11), UPC, Fortran (77/95/2003), OpenMP, Java, Python and PHP applications";
    homepage = "https://github.com/rose-compiler/rose";
    license = licenses.bsd3;
    platforms = platforms.linux;
  };
}
