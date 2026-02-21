{
  lib,
  stdenv,
  rustPlatform,
  fetchFromGitHub,
  makeDesktopItem,
  nix-update-script,

  pkg-config,
  copyDesktopItems,
  makeWrapper,

  hidapi,
  pcsclite,
  udev,
  alsa-lib,
  libxkbcommon,
  wayland,
  libGL,
  vulkan-loader,
  libx11,
  libxcb,

  withGLES ? false,
}:
assert withGLES -> stdenv.hostPlatform.isLinux;
rustPlatform.buildRustPackage (finalAttrs: {

  pname = "picoforge";
  version = "0.3.1-unstable-2026-02-20";

  src = fetchFromGitHub {
    owner = "librekeys";
    repo = "picoforge";
    rev = "0954fab7b4dba5466a15016d72319965b879a465";
    hash = "sha256-9bPDEBp1fdRbVffMPMYdYTJQ7/SFGY2CWYQeqnbUOng=";
  };

  cargoHash = "sha256-/HcwGFV+v282nAdMzEZ4bWQZy0PTIXQ2yOc9IRU75pY=";

  nativeBuildInputs = [
    pkg-config
    copyDesktopItems
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    makeWrapper
  ];

  gpu-lib = if withGLES then libGL else vulkan-loader;

  buildInputs = [
    hidapi
    pcsclite
    udev
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    alsa-lib
    libxkbcommon
    wayland
    finalAttrs.gpu-lib
    libx11
    libxcb
  ];

  postInstall = ''
    install -Dm644 ${finalAttrs.src}/static/appIcons/in.suyogtandel.picoforge.svg $out/share/icons/hicolor/scalable/apps/picoforge.svg
  '';

  postFixup = lib.optionalString stdenv.hostPlatform.isLinux ''
    wrapProgram $out/bin/picoforge --prefix LD_LIBRARY_PATH : "${
      lib.makeLibraryPath [
        wayland
        libxkbcommon
        finalAttrs.gpu-lib
        libx11
        libxcb
      ]
    }"
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "in.suyogtandel.picoforge";
      desktopName = "PicoForge";
      exec = "picoforge";
      terminal = false;
      icon = "picoforge";
      comment = finalAttrs.meta.description;
      categories = [ "Utility" ];
      dbusActivatable = true;
      keywords = [ "Config" ];
      startupNotify = true;
    })
  ];

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version=branch"
      "--use-github-releases"
    ];
  };

  meta = {
    changelog = "https://github.com/librekeys/picoforge/releases/tag/v${finalAttrs.version}";
    description = "Open source commissioning tool for Pico FIDO security keys";
    homepage = "https://github.com/librekeys/picoforge";
    license = lib.licenses.agpl3Only;
    mainProgram = "picoforge";
    platforms = lib.platforms.linux;
  };
})
