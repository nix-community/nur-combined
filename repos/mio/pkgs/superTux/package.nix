{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  pkg-config,
  boost,
  curl,
  SDL2,
  SDL2_image,
  libSM,
  libXext,
  libpng,
  freetype,
  libGLU,
  libGL,
  glew,
  glm,
  openal,
  libogg,
  libvorbis,
  physfs,
  fmt,
  zlib,
  libraqm,
}:

stdenv.mkDerivation rec {
  pname = "supertux";
  version = "0.7.0-rev.1";

  src = fetchFromGitHub {
    owner = "SuperTux";
    repo = "supertux";
    tag = "v${version}";
    hash = "sha256-2eglyRMriDYzAMC480xUM/ZU4bCMK/O+kMCWs4203Lg=";
    fetchSubmodules = true;
  };

  postPatch = ''
    sed '1i#include <memory>' -i external/partio_zip/zip_manager.hpp # gcc12
    # Fix build with cmake 4. Remove for version >= 0.6.4.
    # See <https://github.com/SuperTux/supertux/pull/3093>
    substituteInPlace CMakeLists.txt --replace-fail \
      'cmake_minimum_required(VERSION 3.22)' \
      'cmake_minimum_required(VERSION 4.0)'

    # Fix upstream bug in git_project_version where 'out' variable is undefined
  '';

  nativeBuildInputs = [
    pkg-config
    cmake
  ];

  buildInputs = [
    boost
    curl
    SDL2
    SDL2_image
    libSM
    libXext
    libpng
    freetype
    libGL
    libGLU
    glew
    glm
    openal
    libogg
    libvorbis
    physfs
    fmt
    zlib
    libraqm
  ];

  cmakeFlags = [ "-DENABLE_BOOST_STATIC_LIBS=OFF" ];

  postInstall = ''
    mkdir $out/bin
    ln -s $out/games/supertux2 $out/bin
  '';

  meta = {
    description = "Classic 2D jump'n run sidescroller game";
    homepage = "https://supertux.github.io/";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ pSub ];
    platforms = with lib.platforms; linux;
    mainProgram = "supertux2";
  };
}
