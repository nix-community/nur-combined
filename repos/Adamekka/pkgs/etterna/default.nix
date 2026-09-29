{
  alsa-lib,
  autoPatchelfHook,
  cmake,
  copyDesktopItems,
  desktop-file-utils,
  fetchFromGitHub,
  fontconfig,
  freetype,
  lame,
  lib,
  libGLU,
  libjack2,
  libogg,
  libopus,
  libpulseaudio,
  libvorbis,
  libx11,
  libxext,
  libxinerama,
  libxrandr,
  libxvmc,
  maintainer,
  makeDesktopItem,
  makeWrapper,
  openssl,
  pkg-config,
  rtmpdump,
  shaderc,
  slang,
  stdenv,
  vulkan-headers,
  vulkan-loader,
  zlib,
}:

# Adapted from Nixpkgs' pkgs/by-name/et/etterna/package.nix.
stdenv.mkDerivation (finalAttrs: {
  pname = "etterna";
  version = "0.75.1";

  src = fetchFromGitHub {
    hash = "sha256-wKXp+tjRlAsjXO/10lXoExGdTukr92qwH/jSY5T+V2s=";
    owner = "etternagame";
    repo = "etterna";
    tag = "v${finalAttrs.version}";
  };

  patches = [
    # Resolve virtual game paths before passing them to native filesystem APIs.
    ./fix-download-manager.patch
    ./use-system-shaderc.patch
  ];

  nativeBuildInputs = [
    autoPatchelfHook
    cmake
    copyDesktopItems
    makeWrapper
    pkg-config
  ];

  buildInputs = [
    alsa-lib
    fontconfig
    freetype
    lame
    libGLU
    libjack2
    libogg
    libopus
    libpulseaudio
    libvorbis
    libx11
    libxext
    libxinerama
    libxrandr
    libxvmc
    openssl
    rtmpdump
    shaderc
    slang
    stdenv.cc.cc.lib
    vulkan-headers
    vulkan-loader
    zlib
  ];

  nativeInstallCheckInputs = [ desktop-file-utils ];

  # These backends use dlopen, which is not captured by ELF dependency scanning.
  runtimeDependencies = [
    (lib.getLib alsa-lib)
    (lib.getLib vulkan-loader)
  ];

  cmakeFlags = [
    # Crashpad downloads its own toolchain during the build.
    (lib.cmakeBool "WITH_CRASHPAD" false)
  ];

  preConfigure = ''
    # The bundled FFmpeg and Discord binaries need Nix library paths at link time too.
    autoPatchelf "$PWD/extern/discord/lib/release/libdiscord_partner_sdk.so" "$PWD/extern/ffmpeg/linux-lib"
  '';

  preFixup = ''
    # Relocate bundled libraries before stdenv checks for forbidden build-directory paths.
    autoPatchelf "$out"
  '';

  desktopItems = [
    (makeDesktopItem {
      categories = [
        "ArcadeGame"
        "Game"
      ];
      desktopName = "Etterna";
      exec = "etterna";
      genericName = "Rhythm game";
      icon = "etterna";
      name = "etterna";
      terminal = false;
    })
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p "$out"/{bin,lib/etterna,share/etterna}
    cp -r ../{Announcers,Assets,BGAnimations,BackgroundEffects,BackgroundTransitions,Data,GameTools,NoteSkins,Scripts,Themes} "$out/share/etterna/"
    install -m755 ../Etterna "$out/bin/.etterna-unwrapped"
    cp -P ../extern/ffmpeg/linux-lib/*.so* "$out/lib/etterna/"
    install -m755 ../extern/discord/lib/release/libdiscord_partner_sdk.so "$out/lib/etterna/"
    install -Dm644 ../Docs/images/etterna-logo-light.svg "$out/share/icons/hicolor/scalable/apps/etterna.svg"
    install -Dm644 ../extern/discord/License-Notices.txt "$out/share/licenses/etterna/discord-notices.txt"

    # Keep writable saves separate from immutable assets, using Nixpkgs' existing save location.
    makeWrapper "$out/bin/.etterna-unwrapped" "$out/bin/etterna" \
      --run 'export ETTERNA_ROOT_DIR="$HOME/.local/share/etterna"' \
      --set ETTERNA_ADDITIONAL_ROOT_DIRS "$out/share/etterna"

    runHook postInstall
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck

    desktop-file-validate "$out/share/applications/etterna.desktop"
    # Match the installed store permissions so the logger cannot write into the output.
    chmod a-w "$out/bin"
    # The version action initializes Lua and the theme, then exits before starting gameplay.
    mkdir -p "$TMPDIR/etterna-home"
    if ! HOME="$TMPDIR/etterna-home" timeout 60 "$out/bin/etterna" --version notedataCache > version.log 2>&1; then
      cat version.log
      exit 1
    fi
    grep -F "Etterna v${finalAttrs.version}" version.log

    runHook postInstallCheck
  '';

  meta = {
    changelog = "https://github.com/etternagame/etterna/releases/tag/v${finalAttrs.version}";
    description = "Advanced rhythm game focused on keyboard play";
    homepage = "https://etternaonline.com";
    license = [
      lib.licenses.mit
      # Discord integration links the proprietary Discord Social SDK.
      lib.licenses.unfree
    ];
    mainProgram = "etterna";
    maintainers = [ maintainer ];
    # Upstream only supplies the Linux Discord SDK for x86_64.
    platforms = [ "x86_64-linux" ];
  };
})
