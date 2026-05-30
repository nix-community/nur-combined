{
  lib,
  stdenv,
  fetchFromGitHub,

  # Build
  cmake,
  pkg-config,
  autoPatchelfHook,
  python3,
  file,

  # Media
  ffmpeg,
  mpv,
  lz4,
  libass,
  freetype,
  fontconfig,
  libpng,

  # Graphics
  glew,
  glfw,
  glm,
  libglut,

  # Audio
  libpulseaudio,
  SDL2,
  SDL2_mixer,

  # Wayland
  wayland,
  wayland-protocols,
  wayland-scanner,
  egl-wayland,
  libdecor,

  # X11
  libXau,
  libXdmcp,
  libXpm,
  libXrandr,
  libXxf86vm,

  # Misc
  zlib,
  libffi,
  fftw,
  gmp,

  # Browser engine
  cef-binary,
}:

let
  # Newer CEF required by upstream
  cef = cef-binary.overrideAttrs (_: {
    version = "135.0.17";

    __intentionallyOverridingVersion = true;

    gitRevision = "cbc1c5b";
    chromiumVersion = "135.0.7049.52";

    srcHash =
      {
        aarch64-linux = "sha256-LK5JvtcmuwCavK7LnWmMF2UDpM5iIZOmsuZS/t9koDs=";
        x86_64-linux = "sha256-JKwZgOYr57GuosM31r1Lx3DczYs35HxtuUs5fxPsTcY=";
      }
      .${stdenv.hostPlatform.system} or (throw "Unsupported system: ${stdenv.hostPlatform.system}");
  });

in

stdenv.mkDerivation (finalAttrs: {
  pname = "linux-wallpaperengine";
  version = "0-unstable-2026-05-29";

  src = fetchFromGitHub {
    owner = "Almamu";
    repo = "linux-wallpaperengine";
    rev = "8a00ff79309eb4a117bea1d16eb56a4fb9dc958c";
    hash = "sha256-hdEOGz2WfUiF51yxLUwbpv5Tb4lfhXwvHpHE2hb7+sE=";
    fetchSubmodules = true;
  };

  passthru.updateScript = ./update.sh;

  nativeBuildInputs = [
    cmake
    pkg-config
    autoPatchelfHook
    python3
    file
    wayland-scanner
  ];

  buildInputs = [
    # Media
    ffmpeg
    mpv
    lz4
    libass

    # Fonts
    freetype
    fontconfig

    # Graphics
    glew
    glfw
    glm
    libglut
    libpng

    # Audio
    libpulseaudio
    SDL2
    SDL2_mixer

    # Wayland
    wayland
    wayland-protocols
    egl-wayland
    libdecor

    # X11
    libXau
    libXdmcp
    libXpm
    libXrandr
    libXxf86vm

    # Misc
    zlib
    libffi
    fftw
    gmp
  ];

  cmakeFlags = [
    "-DCMAKE_BUILD_TYPE=${cef.buildType}"
    "-DCEF_ROOT=${cef}"
    "-DUSE_SYSTEM_LIBS=ON"
  ];

  postInstall = ''
    # Remove subproject dev artifacts (keep lib/ for libkissfft-float)
    rm -rf $out/bin $out/include $out/share $out/lib/pkgconfig $out/lib/cmake

    chmod +x $out/linux-wallpaperengine

    mkdir -p $out/bin

    ln -s $out/linux-wallpaperengine $out/bin/linux-wallpaperengine
  '';

  # Fix bundled binaries and runtime lookup
  preFixup = ''
    find $out -maxdepth 1 -type f \
      -exec file {} \; \
      | grep ELF \
      | cut -d: -f1 \
      | while read -r elf; do
          patchelf \
            --shrink-rpath \
            --allowed-rpath-prefixes "$NIX_STORE" \
            "$elf"
        done

    patchelf \
      --set-rpath \
      "${lib.makeLibraryPath finalAttrs.buildInputs}:$out:$out/lib" \
      $out/linux-wallpaperengine
  '';

  meta = {
    description = "Wallpaper Engine backgrounds for Linux";
    homepage = "https://github.com/Almamu/linux-wallpaperengine";
    mainProgram = "linux-wallpaperengine";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    binaryNativeCode = true;
  };
})
