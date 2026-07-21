{
  lib,
  stdenv,
  writeShellApplication,
  makeDesktopItem,
  addDriverRunpath,
  glfw3-minecraft,
  openal,
  alsa-lib,
  libpulseaudio,
  libGL,
  glib,
  libglvnd,
  vulkan-loader,
  glfw3,
  libX11,
  libXcursor,
  libXext,
  libXrandr,
  libXxf86vm,
  libxkbcommon,
  libxtst,
  wayland,
  gtk3,
  electron,
}:

let
  version = "0.63.3";

  srcArgs = {
    owner = "voxelum";
    repo = "x-minecraft-launcher";
    rev = "v${version}";
  };

  runtimeLibs = [
    libGL
    glib
    openal
    libglvnd
    vulkan-loader
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    libX11
    libXxf86vm
    libXext
    libXcursor
    libxkbcommon
    libXrandr
    libxtst
    libpulseaudio
    wayland
    alsa-lib
    gtk3
    glfw3-minecraft
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [ glfw3 ];

  desktopItem = makeDesktopItem {
    name = "XMCL";
    exec = "xmcl %U";
    desktopName = "X Minecraft Launcher";
    comment = "A modern Minecraft launcher";
    categories = [ "Game" ];
    mimeTypes = [ "x-scheme-handler/xmcl" ];
    startupWMClass = "xmcl";
    terminal = false;
    icon = "xmcl";
  };

  mkLauncher =
    {
      resources,
      commandLineArgs ? [ ],
    }:
    writeShellApplication {
      name = "xmcl";
      text = ''
        app=${resources}/share/xmcl/app.asar
        extra_flags=()

        ${lib.optionalString (commandLineArgs != [ ]) ''
          extra_flags+=(${lib.escapeShellArgs commandLineArgs})
        ''}

        ${lib.optionalString stdenv.isLinux ''
          export LD_LIBRARY_PATH="${addDriverRunpath.driverLink}/lib:${lib.makeLibraryPath runtimeLibs}"
          export PULSE_PROP='media.role=game'
          extra_flags+=("--enable-webrtc-pipewire-capturer" "--enable-features=VaapiVideoDecoder,VaapiVideoEncoder")
          if [[ -n "''${NIXOS_OZONE_WL:-}" && -n "''${WAYLAND_DISPLAY:-}" ]]; then
            extra_flags+=("--ozone-platform-hint=auto" "--enable-features=WaylandWindowDecorations" "--enable-wayland-ime=true")
          fi
        ''}

        export XMCL_DISABLE_AUTO_UPDATE=1

        exec ${lib.getExe electron} "''${extra_flags[@]}" "$app" "$@"
      '';
    };

  installIcons = iconDir: ''
    install -Dm644 "${iconDir}/dark@256x256.png" \
      "$out/share/icons/hicolor/256x256/apps/xmcl.png"

    install -Dm644 "${iconDir}/dark@tray.png" \
      "$out/share/icons/hicolor/22x22/apps/tray.png"

    ${lib.optionalString stdenv.isDarwin ''
      install -Dm644 "${iconDir}/dark.icns" \
        "$out/share/xmcl/icons/icon.icns"
    ''}
  '';

  meta = {
    description = "Open Source Minecraft Launcher with Modern UX";
    homepage = "https://github.com/voxelum/x-minecraft-launcher";
    changelog = "https://github.com/voxelum/x-minecraft-launcher/releases/tag/v${version}";
    donationPage = "https://ko-fi.com/ci010";
    license = lib.licenses.mit;
    mainProgram = "xmcl";
    inherit (electron.meta) platforms;
  };
in
{
  inherit
    version
    srcArgs
    runtimeLibs
    desktopItem
    mkLauncher
    installIcons
    meta
    ;
}
