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
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "vectorcraft";
  version = "0.4.0";

  src = fetchFromGitHub {
    owner = "storytold";
    repo = "vectorcraft";
    tag = "v${finalAttrs.version}";
    hash = "sha256-dCkDxRT1oeXfKc3bx8/0E2RImsIt1ESA9orwG9mE6Xo=";
  };

  cargoHash = "sha256-8MKEvl5rxhM7LcQYv2BjArv3er/CDyOyOyS9Vw+oj+Y=";

  nativeBuildInputs = [ copyDesktopItems ];

  cargoBuildFlags = [
    "-p"
    "vectorcraft"
    "-p"
    "vectorcraft-cli"
  ];

  postInstall = ''
    mkdir -p $out/share/icons $out/share/mime/packages
    cp -R assets/app-icon/hicolor $out/share/icons/
    cp packaging/linux/ai.storyteller.vectorcraft.mime.xml $out/share/mime/packages/ai.storyteller.vectorcraft.xml
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "ai.storyteller.vectorcraft";
      desktopName = "VectorCraft";
      genericName = "Vector Graphics Editor";
      comment = "Draw and edit vector illustrations, SVG and PDF";
      exec = "vectorcraft %F";
      tryExec = "vectorcraft";
      icon = "ai.storyteller.vectorcraft";
      terminal = false;
      startupNotify = true;
      startupWMClass = "ai.storyteller.vectorcraft";
      categories = [
        "Graphics"
        "2DGraphics"
        "VectorGraphics"
      ];
      keywords = [
        "vector"
        "illustration"
        "svg"
        "pdf"
        "drawing"
        "bezier"
      ];
      mimeTypes = [
        "image/svg+xml"
        "application/pdf"
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
    } $out/bin/vectorcraft
  '';

  doCheck = false;

  passthru.updateScript = nix-update-script { };

  meta = {
    homepage = "https://getartcraft.com/apps/vectorcraft";
    description = "Open-source, clean-room reimplementation of Adobe Illustrator";
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
