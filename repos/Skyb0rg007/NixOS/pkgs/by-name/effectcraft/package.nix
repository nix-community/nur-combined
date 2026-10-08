{
  lib,
  stdenv,
  fetchFromGitHub,
  rustPlatform,
  nix-update-script,
  copyDesktopItems,
  makeDesktopItem,
  libGL,
  libx11,
  libxcursor,
  libxi,
  libxkbcommon,
  libxrandr,
  vulkan-loader,
  wayland,
  pkg-config,
  alsa-lib,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "effectcraft";
  version = "0.4.0";

  src = fetchFromGitHub {
    owner = "storytold";
    repo = "effectcraft";
    tag = "v${finalAttrs.version}";
    hash = "sha256-p9QrygPos65MYj2R/6n77UT9uIOoXOQ1bJN/Idd84Aw=";
  };

  cargoHash = "sha256-hdUbnK3w7Mum+DqgE0T9USEEB9kTICwQqY694JnZPCA=";

  nativeBuildInputs = [
    pkg-config
    copyDesktopItems
  ];

  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    alsa-lib
  ];

  cargoBuildFlags = [
    "-p"
    "effectcraft"
    "-p"
    "effectcraft-cli"
  ];

  postInstall = ''
    mkdir -p $out/share/icons $out/share/mime/packages
    cp -R assets/app-icon/hicolor $out/share/icons/
    cp packaging/linux/ai.storyteller.effectcraft.mime.xml $out/share/mime/packages/ai.storyteller.effectcraft.xml
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "ai.storyteller.effectcraft";
      desktopName = "EffectCraft";
      genericName = "Motion Graphics Editor";
      comment = "Motion graphics and visual effects compositor";
      exec = "effectcraft %F";
      tryExec = "effectcraft";
      icon = "ai.storyteller.effectcraft";
      terminal = false;
      startupNotify = true;
      startupWMClass = "ai.storyteller.effectcraft";
      categories = [
        "AudioVideo"
        "Video"
        "Graphics"
        "2DGraphics"
      ];
      keywords = [
        "motion"
        "graphics"
        "animation"
        "compositor"
        "effects"
        "keyframe"
        "vfx"
      ];
    })
  ];

  # winit and wgpu dlopen() their windowing and graphics backends.
  postFixup = lib.optionalString stdenv.hostPlatform.isLinux ''
    patchelf --add-rpath ${
      lib.makeLibraryPath [
        libGL
        libx11
        libxcursor
        libxi
        libxkbcommon
        libxrandr
        vulkan-loader
        wayland
      ]
    } $out/bin/effectcraft
  '';

  doCheck = false;

  passthru.updateScript = nix-update-script { };

  meta = {
    homepage = "https://getartcraft.com/apps/effectcraft";
    description = "Open-source, clean-room reimplementation of Adobe After Effects";
    license =
      with lib.licenses;
      OR [
        mit
        asl20
      ];
    platforms = lib.platforms.all;
    hydraPlatforms = [ ];
  };
})
