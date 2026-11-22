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

  patches = lib.optionals stdenv.hostPlatform.isDarwin [
    # Apple Silicon: detect ARM CPU (avoid SSE), skip -msse, keep Nix sysroot,
    # and stop hardcoding CMAKE_OSX_ARCHITECTURES=x86_64.
    ./darwin-apple-silicon.patch
  ];

  # Off by default in nixpkgs; builds and links cleanly with the CET shadow
  # stack, so opt in here.
  hardeningEnable = [ "shadowstack" ];

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
    ois
    sdl2-compat
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    freeglut
    libglvnd
    libGLU
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
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    "-DOGRE_BUILD_LIBS_AS_FRAMEWORKS=OFF"
    "-DCMAKE_OSX_ARCHITECTURES=${stdenv.hostPlatform.darwinArch}"
  ];

  meta = with lib; {
    description = "OGRE 1.x (Object-oriented Graphics Rendering Engine)";
    homepage = "https://www.ogre3d.org/";
    license = licenses.mit;
    platforms = platforms.unix;
  };
})
