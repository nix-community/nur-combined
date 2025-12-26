{
  lib,
  stdenv,
  fetchFromGitHub,
  callPackage,
  qt6,
  kdePackages,
  pkg-config,
  zlib,
  mpv,
  onnxruntime,
  lua5_3_compat,
  aria2,
  aria2Support ? true,
}:
let
  qhttpengine = callPackage ./qhttpengine.nix { };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "kikoplay";
  version = "2.0.0";
  src = fetchFromGitHub {
    owner = "KikoPlayProject";
    repo = "KikoPlay";
    tag = finalAttrs.version;
    hash = "sha256-Rj+U7hs6PGq3BwLUoCRxbTl3lOVd8S5F5Lwb0tG67oM=";
  };

  nativeBuildInputs = [
    pkg-config
    zlib
    qt6.qmake
    qt6.wrapQtAppsHook
    qt6.qtwebengine
    qt6.qtwebsockets
  ];

  buildInputs = [
    mpv
    qhttpengine
    onnxruntime
    kdePackages.qtbase # QOpenGLWidget.h
    kdePackages.qtsvg
    qt6.qtwebengine
    qt6.qtwebsockets
    qt6.qtwayland
  ]
  ++ lib.optional aria2Support aria2;

  strictDeps = true;

  patches = [
    # replace FHS paths in Kikoplay.pro
    ./0001-change-ldflags-and-install-paths.patch
    # replace Qt5 with Qt6 in CMakeLists.txt
    ./0002-fix-cmake-qt-version.patch
  ]
  ++ lib.optionals (stdenv.isLinux && lib.strings.versionAtLeast qt6.qtbase.version "6.9.0") [
    # fix "[libmpv_render] There is already a mpv_render_context set."
    ./0003-fix-mpv-initializeGL.patch
  ];

  postPatch = ''
    substituteInPlace KikoPlay.pro \
      --replace-fail "DEFINES += KSERVICE" "#DEFINES += KSERVICE" \
      --replace-fail "@OUT@" "$out"

    for F in Play/Subtitle/subtitlerecognizer.cpp Extension/App/appmanager.cpp Extension/Script/scriptmanager.cpp LANServer/router.cpp; do
      substituteInPlace "$F" \
        --replace-fail "/usr/share/kikoplay/" "$out/share/kikoplay/"
    done

    # adjust user manual location in usage tip
    sed -i 's|file:///{AppPath}\\KikoPlay使用说明.pdf|file://$out/share/doc/kikoplay|g' res/tip

    # fix - "No cmake_minimum_required command is present" in Extension/Lua/CMakeLists.
    sed -i '1 i\cmake_minimum_required(VERSION 3.21)' Extension/Lua/CMakeLists.txt
  '';

  QT_LDFLAGS = lib.concatMapStringsSep " " (p: "-L${lib.getLib p}/lib") [
    lua5_3_compat
    zlib
    onnxruntime
    mpv
  ];

  qmakeFlags = [ "build.pro" ];

  postFixup = ''
    mkdir -p $out/share/kikoplay/extension/script
    cp -r ${
      (fetchFromGitHub {
        owner = "KikoPlayProject";
        repo = "KikoPlayScript";
        rev = "31dc29fd2fd538eab529f1165697e94bac131737";
        hash = "sha256-3iwm4zMd1yEQ2bFWZqjIGj2IoGUtXl1LEPFlEJjLIew=";
      })
    }/{bgm_calendar,danmu,library,match,resource} $out/share/kikoplay/extension/script/
    mkdir -p $out/share/kikoplay/extension/app
    cp -r ${
      (fetchFromGitHub {
        owner = "KikoPlayProject";
        repo = "KikoPlayApp";
        rev = "e14235dff81408d3047148276de646d93947c875";
        hash = "sha256-cfQcpGYimP9o3R1iao2wxd61kUTE3kpNNq6syM0Ep90=";
      })
    }/app/* $out/share/kikoplay/extension/app/
  '';

  meta = {
    description = "More than a Full-Featured Danmu Player";
    homepage = "https://kikoplay.fun";
    license = lib.licenses.gpl3Only;
    mainProgram = "KikoPlay";
    maintainers = with lib.maintainers; [ xddxdd ];
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
  };
})
