{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  copyDesktopItems,
  makeDesktopItem,
  makeWrapper,
  pkg-config,
  qt6,
  glslang,
  lua5_4,
  openal,
  sfml,
  sol2,
  vulkanscenegraph,
  vsgimgui,
  vsgxchange,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "rrs";
  version = "1.9.0";

  src = fetchFromGitHub {
    owner = "maisvendoo";
    repo = "RRS";
    tag = "v${finalAttrs.version}";
    hash = "sha256-6XLml0iSKNOexvyAj7wVHMQXcxaG13SsMTAiyVySaLg=";
  };

  postPatch = ''
    substituteInPlace filesystem/src/filesystem.cpp \
      --replace-fail "QDir::currentPath().toStdString()" "\"$out/bin\"" \
      --replace-fail "getLevelUpDirectory(workDir, 1)" "\"$out/\""
  '';

  nativeBuildInputs = [
    cmake
    copyDesktopItems
    makeWrapper
    pkg-config
    qt6.qttools
    qt6.wrapQtAppsHook
  ];

  buildInputs = [
    qt6.qtbase
    qt6.qtserialbus
    glslang
    lua5_4
    openal
    sfml
    sol2
    vulkanscenegraph
    vsgimgui
    vsgxchange
  ];

  desktopItems = [
    (makeDesktopItem {
      name = "rrs-launcher";
      type = "Application";
      desktopName = "Russian Railway Simulator";
      icon = "RRS_logo";
      exec = "launcher";
      terminal = false;
      categories = [
        "Simulation"
      ];
    })
  ];

  noAuditTmpdir = true;

  postInstall = ''
    cp -r /build/source/{bin,lib,modules,plugins} $out
    cp -r $src/{cfg,data,docs,fonts,routes,themes} $out
    install -Dm644 $src/launcher/resources/images/RRS_logo.png -t $out/share/icons/hicolor/48x48/apps
  '';

  postFixup = ''
    for f in $out/bin/*; do
      wrapProgram $f \
        --prefix LD_LIBRARY_PATH : $out/lib
    done
  '';

  meta = {
    description = "Russian Railway Simulator";
    homepage = "https://github.com/maisvendoo/RRS";
    license = lib.licenses.gpl2;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.linux;
    skip.ci = stdenv.isDarwin;
    mainProgram = "launcher";
  };
})
