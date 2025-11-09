{
  lib,
  stdenv,
  fetchurl,
  makeDesktopItem,
  wrapGAppsHook3,
  copyDesktopItems,
  imagemagick,
  jdk17,
  jdk21,
  hmclJdk ? jdk21.override {
    enableJavaFX = true; # Necessary for hardware acceleration.
  },
  minecraftJdks ? [
    jdk17
    hmclJdk
  ],
  xorg,
  glib,
  libGL,
  glfw-minecraft ? callPackage ../glfw3-minecraft/package.nix { },
  openal,
  libglvnd,
  alsa-lib,
  wayland,
  vulkan-loader,
  libpulseaudio,
  gobject-introspection,
  callPackage,
  unzip,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "hmcl";
  version = "3.7.3";

  src = fetchurl {
    # HMCL has built-in keys, such as the Microsoft OAuth secret and the CurseForge API key.
    # See https://github.com/HMCL-dev/HMCL/blob/refs/tags/release-3.6.12/.github/workflows/gradle.yml#L26-L28
    url = "https://github.com/HMCL-dev/HMCL/releases/download/v${finalAttrs.version}/HMCL-${finalAttrs.version}.jar";
    hash = "sha256-VE/83KD1xIrkD6BGBK0rJpbKuNPOpmNSC/RHjhRsGco=";
  };

  dontUnpack = true;

  dontWrapGApps = true;

  desktopItems = [
    (makeDesktopItem {
      name = "HMCL";
      exec = "hmcl";
      icon = "hmcl";
      comment = finalAttrs.meta.description;
      desktopName = "HMCL";
      categories = [ "Game" ];
    })
  ];

  nativeBuildInputs = [
    gobject-introspection
    wrapGAppsHook3
    copyDesktopItems
    imagemagick
    unzip
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/{bin,lib/hmcl}
    cp $src $out/lib/hmcl/hmcl.jar

    unzip $src assets/img/icon@8x.png

    for n in 16 32 48 64 96 128 256
    do
      size=$n"x"$n
      mkdir -p $out/share/icons/hicolor/$size/apps
      magick assets/img/icon@8x.png -resize $size $out/share/icons/hicolor/$size/apps/hmcl.png
    done

    runHook postInstall
  '';

  fixupPhase =
    let
      libpath = lib.makeLibraryPath (
        [
          libGL
          glfw-minecraft
          glib
          openal
          libglvnd
          vulkan-loader
        ]
        ++ lib.optionals stdenv.hostPlatform.isLinux [
          xorg.libX11
          xorg.libXxf86vm
          xorg.libXext
          xorg.libXcursor
          xorg.libXrandr
          xorg.libXtst
          libpulseaudio
          wayland
          alsa-lib
        ]
      );
    in
    ''
      runHook preFixup

      makeBinaryWrapper ${hmclJdk}/bin/java $out/bin/hmcl \
        --add-flags "-jar $out/lib/hmcl/hmcl.jar" \
        --set LD_LIBRARY_PATH ${libpath} \
        --prefix PATH : "${lib.makeBinPath minecraftJdks}"\
        ''${gappsWrapperArgs[@]}

      runHook postFixup
    '';

  passthru.updateScript = lib.getExe (callPackage ./update.nix { });

  meta = {
    homepage = "https://hmcl.huangyuhui.net";
    description = "Minecraft Launcher which is multi-functional, cross-platform and popular";
    changelog = "https://docs.hmcl.net/changelog/stable.html";
    mainProgram = "hmcl";
    sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];
    license = lib.licenses.gpl3Only;
    inherit (hmclJdk.meta) platforms;
  };
})
