{
  lib,
  llvmPackages,
  fetchFromGitHub,
  cmake,
  ninja,
  pkg-config,
  kdePackages,
  qt6,
  strip-nondeterminism,
  wrapGAppsHook3,
  zip,
  cubeb,
  curl,
  dbus,
  ffmpeg_8,
  fontconfig,
  freetype,
  gtk3,
  kddockwidgets,
  libbacktrace,
  libGL,
  libjpeg,
  libpcap,
  libpng,
  libwebp,
  libx11,
  libxrandr,
  lz4,
  plutosvg,
  plutovg,
  rapidyaml,
  sdl3,
  shaderc,
  udev,
  vulkan-loader,
  wayland,
  zlib,
  zstd,
}:

let
  pcsx2_patches = fetchFromGitHub {
    owner = "PCSX2";
    repo = "pcsx2_patches";
    rev = "ba8ef4f42c353d8ee44d572f8111b10db54a3f0b";
    hash = "sha256-AiZ2BHNyPX+FmxpZxCbYpRw+C2n3xNaOcXbyH+qqPn8=";
  };

  inherit (qt6)
    qtbase
    qtsvg
    qttools
    qtwayland
    wrapQtAppsHook
    ;
in
llvmPackages.stdenv.mkDerivation (finalAttrs: {
  pname = "pcsx2";
  version = "2.8.2";

  src = fetchFromGitHub {
    pname = "pcsx2-source";
    owner = "PCSX2";
    repo = "pcsx2";
    tag = "v${finalAttrs.version}";
    hash = "sha256-sXVeOTVkd/c04M6BduPl34inqSUoJwfJoWCvpFdR4VQ=";
  };

  postPatch = ''
    substituteInPlace cmake/Pcsx2Utils.cmake \
      --replace-fail 'set(PCSX2_GIT_TAG "")' 'set(PCSX2_GIT_TAG "${finalAttrs.src.tag}")'

    substituteInPlace cmake/SearchForStuff.cmake \
      --replace-fail 'add_subdirectory(3rdparty/cubeb EXCLUDE_FROM_ALL)
    disable_compiler_warnings_for_target(cubeb)
    disable_compiler_warnings_for_target(speex)' 'find_package(cubeb REQUIRED GLOBAL)
    add_library(cubeb ALIAS cubeb::cubeb)'
  '';

  cmakeFlags = [
    (lib.cmakeBool "PACKAGE_MODE" true)
    (lib.cmakeBool "DISABLE_ADVANCE_SIMD" true)
    (lib.cmakeBool "USE_LINKED_FFMPEG" true)
  ];

  nativeBuildInputs = [
    cmake
    ninja
    pkg-config
    strip-nondeterminism
    wrapGAppsHook3
    wrapQtAppsHook
    zip
  ];

  buildInputs = [
    kdePackages.extra-cmake-modules
    cubeb
    curl
    dbus
    ffmpeg_8
    fontconfig
    freetype
    gtk3
    kddockwidgets
    libbacktrace
    libGL
    libjpeg
    libpcap
    libpng
    libwebp
    libx11
    libxrandr
    lz4
    plutosvg
    plutovg
    qtbase
    qtsvg
    qttools
    qtwayland
    rapidyaml
    sdl3
    shaderc
    udev
    wayland
    zlib
    zstd
  ];

  strictDeps = true;

  postInstall = ''
    install -Dm644 $src/pcsx2-qt/resources/icons/AppIcon64.png $out/share/icons/hicolor/64x64/apps/PCSX2.png
    install -Dm644 $src/.github/workflows/scripts/linux/pcsx2-qt.desktop $out/share/applications/PCSX2.desktop

    zip -jq $out/share/PCSX2/resources/patches.zip ${pcsx2_patches}/patches/*
    strip-nondeterminism $out/share/PCSX2/resources/patches.zip
  '';

  qtWrapperArgs =
    let
      libs = lib.makeLibraryPath [
        vulkan-loader
        shaderc
      ];
    in
    [ "--prefix LD_LIBRARY_PATH : ${libs}" ];

  dontWrapGApps = true;

  preFixup = ''
    qtWrapperArgs+=("''${gappsWrapperArgs[@]}")
  '';

  passthru = { inherit pcsx2_patches; };

  meta = {
    description = "Playstation 2 emulator";
    homepage = "https://pcsx2.net";
    changelog = "https://github.com/PCSX2/pcsx2/releases/tag/v${finalAttrs.version}";
    license = with lib.licenses; [
      gpl3Plus
      lgpl3Plus
    ];
    mainProgram = "pcsx2-qt";
    platforms = [ "x86_64-linux" ];
  };
})
