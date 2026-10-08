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
  gtk3,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "filmcraft";
  version = "0.2.1";

  src = fetchFromGitHub {
    owner = "storytold";
    repo = "filmcraft";
    tag = "v${finalAttrs.version}";
    hash = "sha256-7TWsbw/AJthjX60gmfTXMTP3ZXntcga1oo7CfEVyDpc=";
  };

  cargoHash = "sha256-lHtzfEh1t51WIJPQupiIEkQrc+w1l1mt2EYOwulpz+o=";

  nativeBuildInputs = [
    pkg-config
    copyDesktopItems
  ];

  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    alsa-lib
    gtk3
  ];

  cargoBuildFlags = [
    "-p"
    "filmcraft"
    "-p"
    "filmcraft-cli"
  ];

  postInstall = ''
    mkdir -p $out/share/icons $out/share/mime/packages
    cp -R assets/app-icon/hicolor $out/share/icons/
    cp packaging/linux/ai.storyteller.filmcraft.mime.xml $out/share/mime/packages/ai.storyteller.filmcraft.xml
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "ai.storyteller.filmcraft";
      desktopName = "FilmCraft";
      genericName = "Video Editor";
      comment = "Edit video, color and sound";
      exec = "filmcraft %F";
      tryExec = "filmcraft";
      icon = "ai.storyteller.filmcraft";
      terminal = false;
      startupNotify = true;
      startupWMClass = "ai.storyteller.filmcraft";
      categories = [
        "AudioVideo"
        "Video"
        "AudioVideoEditing"
      ];
      keywords = [
        "video"
        "editor"
        "film"
        "timeline"
        "color"
        "grading"
        "nle"
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
    } $out/bin/filmcraft
  '';

  doCheck = false;

  passthru.updateScript = nix-update-script { };

  meta = {
    homepage = "https://getartcraft.com/apps/filmcraft";
    description = "Open-source, clean-room reimplementation of Adobe Premiere Pro";
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
