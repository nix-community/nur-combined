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
}:
let
  version = "1.1.2";

  # The release archive ships no icon; reuse the 32x32 app icon from the repo.
  icon = fetchurl {
    url = "https://raw.githubusercontent.com/XertroV/tm-mumble-bridge/v${version}/assets/icon.ico";
    hash = "sha256-QEIwPX9rUtoNg8NIzKha35sP2T74TXYFTvwGcvKeGes=";
  };

  desktopItem = makeDesktopItem {
    name = "tm-mumble-link";
    desktopName = "TM to Mumble Link";
    comment = "Bridge Trackmania's proximity-chat plugin to Mumble's Link plugin";
    exec = "tm-mumble-link";
    icon = "tm-mumble-link";
    categories = [ "Game" "Audio" ];
    terminal = false;
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

    install -Dm755 tm-mumble-link "$out/bin/tm-mumble-link"
    install -Dm644 LICENSE "$out/share/doc/tm-mumble-link/LICENSE"

    cp ${icon} tm-mumble-link.ico
    icotool -x -o . tm-mumble-link.ico
    install -Dm644 tm-mumble-link_*_32x32x8.png \
      "$out/share/icons/hicolor/32x32/apps/tm-mumble-link.png"

    runHook postInstall
  '';

  desktopItems = [ desktopItem ];

  meta = {
    description = "Bridge Trackmania's proximity-chat plugin to Mumble's Link plugin for positional audio";
    homepage = "https://github.com/XertroV/tm-mumble-bridge";
    changelog = "https://github.com/XertroV/tm-mumble-bridge/releases/tag/v${version}";
    license = lib.licenses.unlicense;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    mainProgram = "tm-mumble-link";
    platforms = lib.platforms.linux;
  };
}
