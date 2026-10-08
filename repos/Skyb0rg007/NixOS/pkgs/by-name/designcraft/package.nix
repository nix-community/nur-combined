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
  pname = "designcraft";
  version = "0.2.1";

  src = fetchFromGitHub {
    owner = "storytold";
    repo = "designcraft";
    tag = "v${finalAttrs.version}";
    hash = "sha256-ejNPIawWXt4Yyow+pgf3dzIRHLaMQYc6BHowwT/x0XE=";
  };

  cargoHash = "sha256-thscwpNiFCERueATWgt2zicv1ZJD8ua95VPMhDZn/j4=";

  nativeBuildInputs = [ copyDesktopItems ];

  cargoBuildFlags = [
    "-p"
    "designcraft"
    "-p"
    "designcraft-cli"
  ];

  postInstall = ''
    mkdir -p $out/share/icons $out/share/mime/packages
    cp -R assets/app-icon/hicolor $out/share/icons/
    cp packaging/linux/ai.storyteller.designcraft.mime.xml $out/share/mime/packages/ai.storyteller.designcraft.xml
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "ai.storyteller.designcraft";
      desktopName = "DesignCraft";
      genericName = "Page Layout";
      comment = "Lay out magazines, books and print documents";
      exec = "designcraft %F";
      tryExec = "designcraft";
      icon = "ai.storyteller.designcraft";
      terminal = false;
      startupNotify = true;
      startupWMClass = "ai.storyteller.designcraft";
      categories = [
        "Graphics"
        "Publishing"
      ];
      keywords = [
        "layout"
        "page"
        "desktop publishing"
        "dtp"
        "magazine"
        "book"
        "indesign"
        "idml"
        "typesetting"
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
    } $out/bin/designcraft
  '';

  doCheck = false;

  passthru.updateScript = nix-update-script { };

  meta = {
    homepage = "https://getartcraft.com/apps/designcraft";
    description = "Open-source, clean-room reimplementation of Adobe InDesign";
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
