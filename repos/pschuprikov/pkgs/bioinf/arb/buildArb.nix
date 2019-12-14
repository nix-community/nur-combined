{ lib, stdenv }: attrs:
stdenv.mkDerivation (attrs // {
  patchPhase = ''
    sed -i -e "/ARBHOME)\\/INCLUDE/d" -e "s/..\\/lib\\///" Makefile
  '' + lib.optionalString (attrs ? patchPhase) attrs.patchPhase;

  preBuild = ''
    makeFlagsArray+=(
      'LINK_SHARED_LIB=''${CXX} -shared -o'
      'LINK_STATIC_LIB=''${AR} rvs'
      'LINK_EXECUTABLE=''${CXX} -o'
      'A_CXX=''${CXX}'
      'A_CC=''${CC}'
      'cxxflags=-DNDEBUG -DARB_64'
      'CXX_INCLUDES=-I.'
      'CC_INCLUDES=-I.'
      'SHARED_LIB_SUFFIX=${lib.removePrefix "." stdenv.hostPlatform.extensions.sharedLibrary}'
      )
  '' + lib.optionalString (attrs ? preBuild) attrs.preBuild;
})
