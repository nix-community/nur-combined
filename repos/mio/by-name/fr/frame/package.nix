{
  lib,
  stdenv,
  rustPlatform,
  fetchFromGitHub,
  nix-update-script,
  pkg-config,
  makeWrapper,
  patchelf,
  writeShellApplication,
  desktopToDarwinBundle,
  apple-sdk_14,
  alsa-lib,
  ffmpeg,
  fontconfig,
  freetype,
  libGL,
  libx11,
  libxcb,
  libxkbcommon,
  libdrm,
  vulkan-loader,
  wayland,
}:

let
  appPackageFlags = [
    "--package"
    "frame-app"
  ];
in
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "frame";
  version = "0.35.0";

  src = fetchFromGitHub {
    owner = "66HEX";
    repo = "frame";
    rev = finalAttrs.version;
    hash = "sha256-PJSgDT3PVHlAy2twZC4f5x7vJrjD3QuAlzkILWo8f4o=";
  };

  cargoHash = "sha256-W2+K/+J0fIWj7+ebcwdn8OXu6K5mco2pqgCWkEn548s=";

  buildAndTestSubdir = "frame-app";
  cargoBuildFlags = appPackageFlags ++ [
    "--bin"
    "frame"
  ];
  cargoTestFlags = appPackageFlags;

  # Native GPUI tests need an active macOS window server. Run the upstream tests
  # on Linux, where the package is built in a normal Nix sandbox.
  doCheck = !stdenv.hostPlatform.isDarwin;

  nativeBuildInputs = [
    pkg-config
    makeWrapper
    patchelf
  ]
  ++ lib.optional stdenv.hostPlatform.isDarwin desktopToDarwinBundle;

  buildInputs =
    lib.optionals stdenv.hostPlatform.isDarwin [ apple-sdk_14 ]
    ++ lib.optionals stdenv.hostPlatform.isLinux [
      alsa-lib
      fontconfig
      freetype
      libGL
      libx11
      libxcb
      libxkbcommon
      libdrm
      vulkan-loader
      wayland
    ];

  postInstall = ''
    install -Dm644 packaging/flathub/io.github._66HEX.Frame.desktop \
      $out/share/applications/io.github._66HEX.Frame.desktop
    install -Dm644 packaging/flathub/io.github._66HEX.Frame.metainfo.xml \
      $out/share/metainfo/io.github._66HEX.Frame.metainfo.xml
    install -Dm644 frame-app/resources/app-icons/32x32.png \
      $out/share/icons/hicolor/32x32/apps/io.github._66HEX.Frame.png
    install -Dm644 frame-app/resources/app-icons/64x64.png \
      $out/share/icons/hicolor/64x64/apps/io.github._66HEX.Frame.png
    install -Dm644 frame-app/resources/app-icons/128x128.png \
      $out/share/icons/hicolor/128x128/apps/io.github._66HEX.Frame.png
    install -Dm644 frame-app/resources/app-icons/128x128@2x.png \
      $out/share/icons/hicolor/256x256/apps/io.github._66HEX.Frame.png
    install -Dm644 frame-app/resources/app-icons/icon.png \
      $out/share/icons/hicolor/512x512/apps/io.github._66HEX.Frame.png

    wrapProgram $out/bin/frame \
      --set FRAME_USE_SYSTEM_MEDIA_TOOLS 1 \
      --set FRAME_FFMPEG_PATH ${lib.getExe ffmpeg} \
      --set FRAME_FFPROBE_PATH ${ffmpeg}/bin/ffprobe \
      --set FRAME_UPDATE_EXPLANATION \
      'This Nix build is managed by Nix. Install updates through your Nix profile, flake, or NixOS configuration.'
  '';

  postFixup = lib.optionalString stdenv.hostPlatform.isLinux ''
    patchelf $out/bin/.frame-wrapped \
      --add-rpath ${
        lib.makeLibraryPath [
          fontconfig
          freetype
          libGL
          libx11
          libxcb
          libxkbcommon
          libdrm
          vulkan-loader
          wayland
        ]
      }
  '';

  passthru.updateScript = writeShellApplication {
    name = "update-frame";
    text = ''
      export UPDATE_NIX_ATTR_PATH="frame"
      exec ${lib.escapeShellArgs (nix-update-script { })} "$@"
    '';
  };

  meta = {
    description = "GPU-accelerated media converter built on FFmpeg";
    homepage = "https://github.com/66HEX/frame";
    changelog = "https://github.com/66HEX/frame/blob/${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.gpl3Plus;
    mainProgram = "frame";
    platforms = [
      "aarch64-darwin"
      "aarch64-linux"
      "x86_64-darwin"
      "x86_64-linux"
    ];
  };
})
