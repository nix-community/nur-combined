{
  lib,
  rustPlatform,
  pkg-config,
  wayland-scanner,
  wrapGAppsHook3,
  writableTmpDirAsHomeHook,
  gtk3,
  libx11,
  libxext,
  libxfixes,
  libxtst,
  wayland,
  libxkbcommon,
  glib,
  pipewire,
  libei,
  SDL2,
  ffmpeg-full,
  pulseaudio,
  libopus,
  pam,
  libgbm,
  libayatana-appindicator,
  wl-clipboard,
  wireplumber,
  xrandr,
  coreutils,
  bash,
  pciutils,
  fontconfig,
  sources,
  source ? sources.uu-remote-linux,
}:

rustPlatform.buildRustPackage {
  inherit (source) pname version src;

  cargoLock = source.cargoLock;

  patches = [ ./tests-ignore-terminal-notifications.patch ];

  postPatch = ''
    substituteInPlace src/terminal.rs \
      --replace-fail '"/bin/bash"' '"${lib.getExe bash}"'
  '';

  nativeBuildInputs = [
    pkg-config
    wayland-scanner
    wrapGAppsHook3
    writableTmpDirAsHomeHook
  ];

  buildInputs = [
    gtk3
    libx11
    libxext
    libxfixes
    libxtst
    wayland
    libxkbcommon
    glib
    pipewire
    libei
    SDL2
  ];

  buildFeatures = [
    "wayland"
    "portal"
    "native-viewer"
    "viewer-sdl"
  ];

  nativeCheckInputs = [ ffmpeg-full ];

  preFixup = ''
    gappsWrapperArgs+=(
      --prefix PATH : ${
        lib.makeBinPath [
          ffmpeg-full
          pulseaudio
          pipewire
          wireplumber
          wl-clipboard
          xrandr
          coreutils
          pciutils
          fontconfig
          glib
        ]
      }
      --prefix LD_LIBRARY_PATH : ${
        lib.makeLibraryPath [
          pam
          libopus
          pulseaudio
          libgbm
          libayatana-appindicator
        ]
      }
    )
  '';

  postInstall = ''
    install -Dm644 contrib/desktop/*.desktop -t $out/share/applications
    install -Dm644 contrib/desktop/uu-remote-linux.svg \
      $out/share/icons/hicolor/scalable/apps/uu-remote-linux.svg
    install -Dm644 packaging/deb/uuremote-native.service \
      $out/lib/systemd/user/uuremote-native.service
    substituteInPlace $out/lib/systemd/user/uuremote-native.service \
      --replace-fail /usr/bin/uuremote-server $out/bin/uuremote-server
  '';

  doInstallCheck = true;
  # Upstream has no version output for versionCheckHook.
  postInstallCheck = ''
    $out/bin/uuremote-server --help
    $out/bin/uuremote-viewer --help
  '';

  meta = {
    description = "Unofficial Linux host and viewer for NetEase UU Remote";
    homepage = "https://github.com/VallierDev/uu-remote-linux";
    changelog = "https://github.com/VallierDev/uu-remote-linux/releases/tag/v${source.version}";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ moraxyc ];
    mainProgram = "uuremote-server";
    platforms = lib.platforms.linux;
  };
}
