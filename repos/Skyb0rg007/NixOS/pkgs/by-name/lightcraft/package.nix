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
  pname = "lightcraft";
  version = "0.2.1";

  src = fetchFromGitHub {
    owner = "storytold";
    repo = "lightcraft";
    tag = "v${finalAttrs.version}";
    hash = "sha256-c3nDkkncBiR+stfI0JGFkWLB5/R6bqeb5wlC6Tx3US0=";
  };

  cargoHash = "sha256-stmE3EJiCH75000wF8qFrxbEy2egF3yhshLUTIzagUE=";

  nativeBuildInputs = [ copyDesktopItems ];

  cargoBuildFlags = [
    "-p"
    "lightcraft"
    "-p"
    "lightcraft-cli"
  ];

  postInstall = ''
    mkdir -p $out/share/icons $out/share/mime/packages
    cp -R assets/app-icon/hicolor $out/share/icons/
    cp packaging/linux/ai.storyteller.lightcraft.mime.xml $out/share/mime/packages/ai.storyteller.lightcraft.xml
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "ai.storyteller.lightcraft";
      desktopName = "LightCraft";
      genericName = "Photo Library and Raw Developer";
      comment = "Organise photos and develop raw files, non-destructively";
      exec = "lightcraft %F";
      icon = "ai.storyteller.lightcraft";
      terminal = false;
      startupWMClass = "ai.storyteller.lightcraft";
      categories = [
        "Graphics"
        "2DGraphics"
        "RasterGraphics"
        "Photography"
      ];
      keywords = [
        "photo"
        "raw"
        "camera"
        "library"
        "develop"
      ];
      mimeTypes = [
        "image/jpeg"
        "image/png"
        "image/tiff"
        "image/webp"
        "image/x-adobe-dng"
        "image/x-sony-arw"
        "image/x-canon-cr2"
        "image/x-canon-cr3"
        "image/x-nikon-nef"
        "image/x-fuji-raf"
        "image/x-olympus-orf"
        "image/x-panasonic-rw2"
        "image/x-pentax-pef"
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
    } $out/bin/lightcraft
  '';

  doCheck = false;

  passthru.updateScript = nix-update-script { };

  meta = {
    homepage = "https://getartcraft.com/apps/lightcraft";
    description = "Open-source, clean-room reimplementation of Adobe Lightroom";
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
