{
  lib,
  stdenv,
  fetchurl,
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
  version = "0.7.0-beta.1";

  src = fetchurl {
    url = "https://github.com/SuperTux/supertux/releases/download/v${version}/SuperTux-v${version}-Source.tar.gz";
    sha256 = "sha256-3n+NGkVWp0770BUbhIAvcKtyuquf5jtOOCQlsYtqfEE=";
  };

  postPatch = ''
    sed '1i#include <memory>' -i external/partio_zip/zip_manager.hpp # gcc12
    # Fix build with cmake 4. Remove for version >= 0.6.4.
    # See <https://github.com/SuperTux/supertux/pull/3093>
    substituteInPlace CMakeLists.txt --replace-fail \
      'cmake_minimum_required(VERSION 3.22)' \
      'cmake_minimum_required(VERSION 4.0)'

    substituteInPlace external/sexp-cpp/CMakeLists.txt --replace-fail \
      'cmake_minimum_required(VERSION 3.0)' \
      'cmake_minimum_required(VERSION 4.0)'

    substituteInPlace external/tinygettext/CMakeLists.txt --replace-fail \
      'cmake_minimum_required(VERSION 3.0)' \
      'cmake_minimum_required(VERSION 4.0)'
    substituteInPlace external/SDL_ttf/CMakeLists.txt --replace-fail \
      'cmake_minimum_required(VERSION 3.0)' \
      'cmake_minimum_required(VERSION 4.0)'
    substituteInPlace external/discord-sdk/CMakeLists.txt --replace-fail \
      'cmake_minimum_required (VERSION 3.2.0)' \
      'cmake_minimum_required (VERSION 4.0)'

    # Fix upstream bug in git_project_version where 'out' variable is undefined
    substituteInPlace mk/cmake/GetGitRevisionDescription.cmake --replace-fail \
      'parent_set(''${out} ''${out}-NOTFOUND)' \
      '# parent_set(''${out} ''${out}-NOTFOUND)'
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
