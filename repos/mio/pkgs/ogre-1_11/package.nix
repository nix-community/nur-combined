{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  ninja,
  pkg-config,
  boost,
  freetype,
  libpng,
  zziplib,
  pugixml,
  freeglut,
  libglvnd,
  libGLU,
  libx11,
  libxaw,
  libxmu,
  libxrandr,
  libxt,
  libxxf86vm,
  xorgproto,
  libice,
  libsm,
  libxrender,
  ois,
  sdl2-compat,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "ogre";
  version = "1.11.6";

  src = fetchFromGitHub {
    owner = "OGRECave";
    repo = "ogre";
    rev = "v${finalAttrs.version}";
    hash = "sha256-lCRa3sloF0o7Wz8QAuPyJTXYrvNmAfuKsz/DzjgSyls=";
  };

  nativeBuildInputs = [
    cmake
    ninja
    pkg-config
  ];

  buildInputs = [
    boost
    freetype
    libpng
    zziplib
    pugixml
    freeglut
    libglvnd
    libGLU
    ois
    sdl2-compat
    libice
    libsm
    libx11
    libxaw
    libxmu
    libxrandr
    libxrender
    libxt
    libxxf86vm
    xorgproto
  ];

  cmakeFlags = [
    "-DCMAKE_POLICY_VERSION_MINIMUM=3.5"
    "-DOGRE_BUILD_SAMPLES=OFF"
    "-DOGRE_BUILD_TESTS=OFF"
    "-DOGRE_BUILD_TOOLS=OFF"
  ];

  meta = with lib; {
    description = "OGRE 1.x (Object-oriented Graphics Rendering Engine)";
    homepage = "https://www.ogre3d.org/";
    license = licenses.mit;
    platforms = platforms.linux;
  };
})
