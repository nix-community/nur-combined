{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchurl,
  cmake,
  libarchive,
  libxml2,
  libxslt,
  curl,
  boost,
  antlr2,
  ctpl,
  jre,
  pandoc,
  doxygen,
}:

stdenv.mkDerivation rec {
  pname = "srcml";
  # version = "1.0.0"; # 2020-01-27
  version = "unstable-2025-07-30";

  src = fetchFromGitHub {
    owner = "srcML";
    repo = "srcML";
    # rev = "v${version}";
    # https://github.com/srcML/srcML/tree/develop
    rev = "82432652d9e753605c46b788161123cef56090b5";
    hash = "sha256-1PcOgY9aCGUz2M29wyi0M5dri/G6CuI++ZGRH/t8moI=";
  };

  patches = [
    # fix: error: 'transform' is not a member of 'std'
    # https://github.com/srcML/srcML/pull/1829
    (fetchurl {
      url = "https://github.com/srcML/srcML/pull/1829/commits/3a040d745f68cff4956a62a1bac3b020a5136ca6.patch";
      hash = "sha256-sxkxu/YgAAIsPhgpstO9gJcARfkR+A664U2jJBZU72E=";
    })
  ];

  cmakeFlags = [
    # https://discourse.nixos.org/t/dealing-with-cmake-fetchcontent/34768
    # this works without adding "FIND_PACKAGE_ARGS NAMES cli11" to "FetchContent_Declare(cli11" etc
    "-DFETCHCONTENT_SOURCE_DIR_CLI11=external/cli11"
    "-DFETCHCONTENT_SOURCE_DIR_CTPL_STL_SRC=external/ctpl_stl"
    "-DFETCHCONTENT_SOURCE_DIR_TINYSHA1=${src_tinysha1}"
    "-DFETCHCONTENT_SOURCE_DIR_ANTLRSRC=external/antlrsrc"
    "-DBUILD_EXAMPLES=ON"
    "-DBUILD_ALL_DOCS=ON"
  ];

  # src/client/CMakeLists.txt
  src_CLI11_hpp = fetchurl {
    url = "https://github.com/CLIUtils/CLI11/releases/download/v2.5.0/CLI11.hpp";
    hash = "sha256-S/CpSQqnIJF2zNpwVE+VQT5ZTSIHzKM8nNGN7RiaY6Y=";
  };

  # src/client/CMakeLists.txt
  src_ctpl_stl = fetchFromGitHub {
    owner = "vit-vit";
    repo = "CTPL";
    rev = "ctpl_v.0.0.2";
    hash = "sha256-O9l7k1/2fVfEcyfJmWzXmju6TRQHK+NZFoaYmdd5KRg=";
  };

  # src/parser/CMakeLists.txt
  src_tinysha1 = fetchFromGitHub {
    owner = "mohaps";
    repo = "tinysha1";
    rev = "2795aa8de91b1797defdfbff61ed93b22b5ced81";
    hash = "sha256-oPZpqJKf6SHOD/bWG5IqtoODGlnQ9qsBiZ9FAY2Awd4=";
  };

  # src/parser/CMakeLists.txt
  # https://github.com/antlr/website-antlr2/blob/gh-pages/download/antlr-2.7.7.tar.gz
  src_antlrsrc = stdenv.mkDerivation {
    name = "antlr-2.7.7";
    src = fetchurl {
      url = "https://www.antlr2.org/download/antlr-2.7.7.tar.gz";
      hash = "sha256-hTrrAhrvdYa9op50prAwBry1ZadVyGtmAy2Owxtn27k=";
    };
    installPhase = ''
      cp -r . $out
    '';
  };

  # TODO darwin
  # src/client/macos-libarchive.cmake
  # FetchContent_Declare(libarchiveInclude1
  # FetchContent_Declare(libarchiveInclude

  postUnpack = ''
    pushd $sourceRoot
    # src/client/CMakeLists.txt
    CMAKE_EXTERNAL_SOURCE_DIR=build/external
    mkdir -p $CMAKE_EXTERNAL_SOURCE_DIR
    cd $CMAKE_EXTERNAL_SOURCE_DIR
    mkdir cli11
    cp ${src_CLI11_hpp} cli11/CLI11.hpp
    cp -r ${src_ctpl_stl} ctpl_stl
    chmod -R +w ctpl_stl
    # fix: CMake Error: file failed to open for writing
    cp -r ${src_antlrsrc} antlrsrc
    chmod -R +w antlrsrc
    popd
  '';

  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace \
        "add_subdirectory(package)" \
        "# add_subdirectory(package)"
  '';

  nativeBuildInputs = [
    cmake
    jre
    # to build docs
    pandoc
    doxygen
  ];

  buildInputs = [
    libarchive
    libxml2
    libxslt
    curl
    boost
    antlr2
  ];

  meta = {
    description = "SrcML Toolkit";
    homepage = "https://github.com/srcML/srcML";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "srcml";
    platforms = lib.platforms.all;
  };
}
