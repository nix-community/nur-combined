{
  autoPatchelfHook,
  buildNpmPackage,
  callPackage,
  copyDesktopItems,
  electron,
  ffmpeg,
  imagemagick,
  lib,
  makeDesktopItem,
  makeWrapper,
  nodejs_22,
  source ? callPackage ./source.nix { },
  stdenv,
  which,
  zip,
}:

buildNpmPackage (finalAttrs: {
  pname = "yanhekt-autoslides";
  inherit (source) npmDepsHash src version;

  sourceRoot = "${finalAttrs.src.name}/autoslides";

  nodejs = nodejs_22;
  makeCacheWritable = true;
  npmRebuildFlags = [ "--ignore-scripts" ];
  npmBuildScript = "package";

  env.ELECTRON_SKIP_BINARY_DOWNLOAD = "1";

  nativeBuildInputs = [
    autoPatchelfHook
    copyDesktopItems
    imagemagick
    makeWrapper
    zip
  ];

  buildInputs = [ stdenv.cc.cc.lib ];

  postPatch = ''
    substituteInPlace forge.config.ts \
      --replace-fail \
        "icon: 'resources/img/icon'," \
        "electronZipDir: path.resolve(__dirname, '.electron-packager/electron-zips'), icon: 'resources/img/icon'," \
      --replace-fail \
        "...(!isDev ? [new FusesPlugin({" \
        "...(false ? [new FusesPlugin({"

    for file in \
      src/main/infra/ffmpegService.ts \
      src/main/infra/onnxModelService.ts \
      src/main/infra/sharpService.ts \
      src/main/extraction/qtExtractorService.ts
    do
      substituteInPlace "$file" \
        --replace-fail \
          "process.resourcesPath" \
          "(process.env.AUTOSLIDES_RESOURCES_PATH || process.resourcesPath)"
    done
  '';

  postConfigure = ''
    substituteInPlace node_modules/@electron-forge/core-utils/dist/electron-version.js \
      --replace-fail "return version" "return '${electron.version}'"

    electron_zip="$PWD/.electron-packager/electron-zips/electron-v${electron.version}-${stdenv.hostPlatform.node.platform}-${stdenv.hostPlatform.node.arch}.zip"
    mkdir -p "$(dirname "$electron_zip")"
    touch electron
    zip "$electron_zip" electron
    rm electron
  '';

  doCheck = true;
  checkPhase = ''
    runHook preCheck

    npm test

    runHook postCheck
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/share/yanhekt-autoslides"
    cp -r out/AutoSlides-linux-*/resources "$out/share/yanhekt-autoslides/"
    rm -rf \
      "$out/share/yanhekt-autoslides/resources/@img/"*linuxmusl* \
      "$out/share/yanhekt-autoslides/resources/ffmpeg-static" \
      "$out/share/yanhekt-autoslides/resources/ffprobe-static"

    makeWrapper ${lib.getExe electron} "$out/bin/autoslides" \
      --add-flags "$out/share/yanhekt-autoslides/resources/app.asar" \
      --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime=true}}" \
      --prefix PATH : "${
        lib.makeBinPath [
          ffmpeg
          which
        ]
      }" \
      --set AUTOSLIDES_RESOURCES_PATH "$out/share/yanhekt-autoslides/resources" \
      --set ELECTRON_FORCE_IS_PACKAGED 1 \
      --inherit-argv0

    install -d "$out/share/icons/hicolor/512x512/apps"
    magick resources/img/icon.png -resize 512x512 \
      "$out/share/icons/hicolor/512x512/apps/autoslides.png"

    runHook postInstall
  '';

  # FIXME:
  # patchelf can relocate libvips' .init without updating DT_INIT (NixOS/patchelf#639).
  # Patch the other ELF files, then restore libvips; Sharp's addon supplies its C++ runtime.
  dontAutoPatchelf = true;
  postFixup = ''
    autoPatchelf "$out"

    for libvips in "$out"/share/yanhekt-autoslides/resources/@img/sharp-libvips-linux-*; do
      cp node_modules/@img/"''${libvips##*/}"/lib/libvips-cpp.so.* "$libvips/lib/"
    done
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "autoslides";
      desktopName = "AutoSlides";
      comment = finalAttrs.meta.description;
      exec = "autoslides %U";
      icon = "autoslides";
      categories = [ "Education" ];
      terminal = false;
      startupWMClass = "AutoSlides";
    })
  ];

  meta = {
    description = "北京理工大学延河课堂第三方客户端";
    homepage = "https://github.com/BIT-Admin/Yanhekt-AutoSlides";
    changelog = "https://github.com/BIT-Admin/Yanhekt-AutoSlides/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.asl20;
    mainProgram = "autoslides";
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
  };
})
