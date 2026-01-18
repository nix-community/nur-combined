{
  lib,
  stdenv,
  src,
  cmake,
  ninja,
  pkg-config,
  boost,
  freetype,
  util-linuxMinimal,
  ois,
  libglvnd,
  libGLU,
  xorg,
  ogre,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "mygui";
  version = "3.4.3";

  inherit src;

  nativeBuildInputs = [
    cmake
    ninja
    pkg-config
  ];

  buildInputs = [
    boost
    freetype
    util-linuxMinimal
    ois
    libglvnd
    libGLU
    xorg.libX11
    ogre
  ];

  cmakeFlags = [
    "-DMYGUI_RENDERSYSTEM=3"
    "-DMYGUI_BUILD_DEMOS=OFF"
    "-DMYGUI_BUILD_TOOLS=OFF"
    "-DMYGUI_BUILD_PLUGINS=OFF"
    "-DMYGUI_BUILD_UNITTESTS=OFF"
    "-DMYGUI_BUILD_WRAPPER=OFF"
    "-DMYGUI_INSTALL_DOCS=OFF"
  ];

  meta = with lib; {
    description = "MyGUI with OGRE render system";
    homepage = "https://mygui.info/";
    license = licenses.mit;
    platforms = platforms.linux;
  };
})
