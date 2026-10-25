{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  pipewire,
  dbus,
  fontconfig,
  freetype,
  libxkbcommon,
  libGL,
  wayland,
  vulkan-loader,
  libx11,
  libxcb,
  libxcursor,
  libxi,
  libxrandr,
}:

let
  # Loaded via dlopen by winit/glutin/x11-dl at runtime
  runtimeLibs = [
    libGL
    libxkbcommon
    wayland
    vulkan-loader
    libx11
    libxcursor
    libxi
    libxrandr
  ];
in
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "region-to-share";
  version = "2.1.1";

  src = fetchFromGitHub {
    owner = "solarpush";
    repo = "region-to-share";
    tag = finalAttrs.version;
    hash = "sha256-gtWItZJHammyA8K7Tjq/NCYMYoo2oWecWw6Bel/tPJY=";
  };

  patches = [
    # The PipeWire process callback copies full frames on the RT data thread;
    # RTKit's RLIMIT_RTTIME then gets the app SIGKILLed once a stream starts.
    ./no-rt-process.patch
  ];

  cargoHash = "sha256-hvu/zdp/FsAm70ap1bNo/RqOMdGPrtpmKgsV4mH9pxc=";

  nativeBuildInputs = [
    pkg-config
    rustPlatform.bindgenHook
  ];

  buildInputs = [
    pipewire
    dbus
    fontconfig
    freetype
    libxkbcommon
    wayland
    libx11
    libxcb
  ];

  cargoBuildFlags = [
    "--package"
    "region-ui-egui"
  ];

  postInstall = ''
    mv $out/bin/region-ui-egui $out/bin/region-to-share

    install -Dm644 io.github.solarpush.RegionToShare.desktop -t $out/share/applications
    install -Dm644 io.github.solarpush.RegionToShare.metainfo.xml -t $out/share/metainfo
    for size in 16 24 32 48 64 128 256 512; do
      install -Dm644 images/region-to-share-$size.png \
        $out/share/icons/hicolor/''${size}x''${size}/apps/io.github.solarpush.RegionToShare.png
    done
    install -Dm644 images/region-to-share.svg \
      $out/share/icons/hicolor/scalable/apps/io.github.solarpush.RegionToShare.svg
  '';

  postFixup = ''
    patchelf --add-rpath ${lib.makeLibraryPath runtimeLibs} $out/bin/region-to-share
  '';

  meta = {
    description = "Draw and share a region of your screen in video calls";
    homepage = "https://github.com/solarpush/region-to-share";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ mrene ];
    platforms = lib.platforms.linux;
    mainProgram = "region-to-share";
  };
})
