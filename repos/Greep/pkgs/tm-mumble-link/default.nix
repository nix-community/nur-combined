{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  icoutils,
  copyDesktopItems,
  makeDesktopItem,
  libxkbcommon,
  wayland,
  libGL,
  libx11,
  libxcursor,
  libxrandr,
  libxi,
  vulkan-loader,
  tuiVersion ? false,
}:
let
  version = "1.1.2";

  # The release archive ships no icon; reuse the 32x32 app icon from the repo.
  icon = fetchurl {
    url = "https://raw.githubusercontent.com/XertroV/tm-mumble-bridge/v${version}/assets/icon.ico";
    hash = "sha256-QEIwPX9rUtoNg8NIzKha35sP2T74TXYFTvwGcvKeGes=";
  };
in
stdenv.mkDerivation {
  pname = "tm-mumble-link";
  inherit version;

  src = fetchurl {
    url = "https://github.com/XertroV/tm-mumble-bridge/releases/download/v${version}/tm-mumble-link-v${version}-linux-x86_64.tar.gz";
    hash = "sha256-CaRaPMvNoBuwCFlpFW6bPLgtAFFMU0JH8VsC9shTu4E=";
  };

  # The tarball has no top-level directory: files sit at the archive root.
  sourceRoot = ".";

  nativeBuildInputs = [
    autoPatchelfHook
    copyDesktopItems
    icoutils
  ];

  buildInputs = [
    stdenv.cc.cc.lib
  ]
  ++ lib.optionals (!tuiVersion) [
    libxkbcommon
    wayland
    libGL
    libx11
    libxcursor
    libxrandr
    libxi
    vulkan-loader
  ];

  # winit/wgpu/egui open their backends with dlopen at runtime, so none of the
  # libraries above ever show up in the binary's NEEDED list. autoPatchelfHook
  # only patches NEEDED entries, which leaves an RPATH holding little more than
  # libgcc_s, and the GUI then aborts at startup with
  # `WaylandError(Connection(NoWaylandLib))`. runtimeDependencies is the hook's
  # supported way to force dlopen'd libraries into the RPATH.
  # The TUI binary is headless and needs none of this.
  runtimeDependencies = lib.optionals (!tuiVersion) [
    libxkbcommon
    wayland
    libGL
    libx11
    libxcursor
    libxrandr
    libxi
    vulkan-loader
  ];

  installPhase = ''
    runHook preInstall
  '' + lib.optionalString (!tuiVersion) ''
    install -Dm755 tm-mumble-link "$out/bin/tm-mumble-link"
  '' + lib.optionalString tuiVersion ''
    install -Dm755 tm-mumble-link-tui "$out/bin/tm-mumble-link-tui"
  '' + ''
    install -Dm644 LICENSE "$out/share/doc/tm-mumble-link/LICENSE"

    cp ${icon} tm-mumble-link.ico
    icotool -x -o . tm-mumble-link.ico
    install -Dm644 tm-mumble-link_*_32x32x8.png \
      "$out/share/icons/hicolor/32x32/apps/tm-mumble-link.png"

    runHook postInstall
  '';

  desktopItems =
    lib.optionals (!tuiVersion) [
      (makeDesktopItem {
        name = "tm-mumble-link";
        desktopName = "TM to Mumble Link";
        comment = "Bridge Trackmania's proximity-chat plugin to Mumble's Link plugin";
        exec = "tm-mumble-link";
        icon = "tm-mumble-link";
        categories = [ "Game" "Audio" ];
        terminal = false;
      })
    ]
    ++ lib.optionals tuiVersion [
      (makeDesktopItem {
        name = "tm-mumble-link-tui";
        desktopName = "TM to Mumble Link (TUI)";
        comment = "Bridge Trackmania's proximity-chat plugin to Mumble's Link plugin";
        exec = "tm-mumble-link-tui";
        icon = "tm-mumble-link";
        categories = [ "Game" "Audio" ];
        terminal = true;
      })
    ];

  meta = {
    description = "Bridge Trackmania's proximity-chat plugin to Mumble's Link plugin for positional audio";
    homepage = "https://github.com/XertroV/tm-mumble-bridge";
    changelog = "https://github.com/XertroV/tm-mumble-bridge/releases/tag/v${version}";
    license = lib.licenses.unlicense;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    platforms = lib.platforms.linux;
  }
  // lib.optionalAttrs (!tuiVersion) { mainProgram = "tm-mumble-link"; }
  // lib.optionalAttrs tuiVersion { mainProgram = "tm-mumble-link-tui"; };
}
