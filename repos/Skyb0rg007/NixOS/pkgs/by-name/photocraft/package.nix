{
  lib,
  stdenv,
  fetchFromGitHub,
  rustPlatform,
  nix-update-script,
  copyDesktopItems,
  makeWrapper,
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
  pname = "photocraft";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "storytold";
    repo = "photocraft";
    tag = "v${finalAttrs.version}";
    hash = "sha256-MpvMiONXNd3w/NUQI3xZ8SKJFor42w0sxHHEFHnXgGw=";
  };

  cargoHash = "sha256-GytJ3eaPf18GDgAPxbKCZ6ibrxzLcnht4KLC/0UxrbM=";

  nativeBuildInputs = [
    copyDesktopItems
    makeWrapper
  ];

  cargoBuildFlags = [
    "-p"
    "photocraft"
    "-p"
    "photocraft-cli"
  ];

  postInstall = ''
    mkdir -p $out/share/icons $out/share/mime/packages
    cp -R assets/app-icon/hicolor $out/share/icons/
    cp packaging/linux/ai.storyteller.photocraft.mime.xml $out/share/mime/packages/ai.storyteller.photocraft.xml
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "ai.storyteller.photocraft";
      desktopName = "PhotoCraft";
      genericName = "Image Editor";
      comment = "Edit photos and layered PSD documents";
      exec = "photocraft %F";
      tryExec = "photocraft";
      icon = "ai.storyteller.photocraft";
      terminal = false;
      startupNotify = true;
      startupWMClass = "photocraft";
      categories = [
        "Graphics"
        "2DGraphics"
        "RasterGraphics"
        "Photography"
      ];
      keywords = [
        "photo"
        "image"
        "editor"
        "psd"
        "photoshop"
        "layers"
        "retouch"
        "paint"
      ];
      mimeTypes = [
        "application/x-photocraft"
        "image/vnd.adobe.photoshop"
        "image/x-psd"
        "image/x-psb"
        "image/png"
        "image/jpeg"
        "image/tiff"
        "image/webp"
        "image/gif"
        "image/bmp"
        "image/x-tga"
        "image/x-icon"
        "image/vnd.microsoft.icon"
        "image/x-portable-anymap"
        "image/x-portable-bitmap"
        "image/x-portable-graymap"
        "image/x-portable-pixmap"
        "image/x-exr"
        "image/vnd.radiance"
        "image/avif"
        "image/qoi"
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
    } $out/bin/photocraft
    # Its startup check only consults ldconfig and /usr/lib, so it can't see the RPATH above.
    wrapProgram $out/bin/photocraft --set-default PHOTOCRAFT_SKIP_LIB_CHECK 1
  '';

  doCheck = false;

  passthru.updateScript = nix-update-script { };

  meta = {
    homepage = "https://getartcraft.com/apps/photocraft";
    description = "Open-source, clean-room reimplementation of Adobe Photoshop";
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
