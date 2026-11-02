{
  lib,
  stdenv,
  callPackage,
  fetchurl,
  _7zz,
  common-updater-scripts,
  copyDesktopItems,
  curl,
  electron_41,
  libicns,
  makeDesktopItem,
  makeWrapper,
  writeShellApplication,
  yq-go,
}:

let
  # Pinned: callPackage would otherwise inject the top-level `electron` (newer V8
  # API) and the prebuilt native addon does not compile against it.
  electron = electron_41;

  inherit (stdenv.hostPlatform) isDarwin isLinux;

  appName = "九分学长考雅机考平台";
  updateFeed = "https://static.9fnnn.com/electron/stable";
in
stdenv.mkDerivation (finalAttrs: {
  pname = "jiufenxuezhang-ielts";
  version = "0.9.19-rc.2";

  __structuredAttrs = true;
  strictDeps = true;

  src = fetchurl {
    url = "${updateFeed}/jiufenxuezhang-ielts-${finalAttrs.version}-universal.dmg";
    hash = "sha512-dvoE6a8xANcECtep0Sg6yWRtlxa1FVyc2fX/pnEogygay4udyAGC6ze4PsVmnP+kUeeMtEM2FUB7+6fkDBHDGQ==";
  };

  nativeBuildInputs = [
    _7zz
    makeWrapper
  ]
  ++ lib.optionals isLinux [
    libicns
    copyDesktopItems
  ];

  unpackPhase = ''
    runHook preUnpack
    7zz x -bso0 -bsp0 $src
    find . -name '*:com.apple.*' -delete
    mv "${appName} ${finalAttrs.version}/${appName}.app" app
    runHook postUnpack
  '';

  dontFixup = isDarwin;
  sourceRoot = if isDarwin then "app" else "app/Contents/Resources";

  installPhase = ''
    runHook preInstall
  ''
  + lib.optionalString isDarwin ''
    mkdir -p $out/Applications
    cp -R . "$out/Applications/${appName}.app"
    makeWrapper "$out/Applications/${appName}.app/Contents/MacOS/${appName}" \
      $out/bin/jiufenxuezhang-ielts
  ''
  + lib.optionalString isLinux ''
    res=$out/share/jiufenxuezhang-ielts/resources
    mkdir -p $res
    cp app.asar $res/
    mod=node_modules/better-sqlite3-multiple-ciphers
    mkdir -p $res/app.asar.unpacked/$mod/build/Release
    cp -r app.asar.unpacked/$mod/{lib,package.json,LICENSE} $res/app.asar.unpacked/$mod/
    install -Dm755 ${finalAttrs.passthru.better-sqlite3-mc}/lib/better_sqlite3.node $res/app.asar.unpacked/$mod/build/Release/better_sqlite3.node

    icns2png -x icon.icns
    for f in icon_*x*x32.png; do
      size=''${f#icon_}; size=''${size%%x*}
      install -Dm644 $f $out/share/icons/hicolor/''${size}x''${size}/apps/jiufenxuezhang-ielts.png
    done

    makeWrapper ${lib.getExe electron} $out/bin/jiufenxuezhang-ielts \
      --add-flags $res/app.asar \
      --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime=true}}" \
      --set-default XXGG_API_MODE online \
      --inherit-argv0
  ''
  + ''
    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "jiufenxuezhang-ielts";
      desktopName = appName;
      genericName = "IELTS Computer-delivered Test Practice";
      exec = "jiufenxuezhang-ielts %U";
      icon = "jiufenxuezhang-ielts";
      categories = [ "Education" ];
      mimeTypes = [ "x-scheme-handler/xxgg" ];
      startupWMClass = appName;
    })
  ];

  passthru = {
    # Must be built against the same Electron that runs the app.
    better-sqlite3-mc = callPackage ./better-sqlite3-multiple-ciphers.nix { inherit electron; };

    # nix-update auto -u
    # Run from the repository root. The feed's base64 sha512 is already a valid
    # SRI hash once prefixed, so nothing needs to be downloaded.
    updateScript = lib.getExe (writeShellApplication {
      name = "update-${finalAttrs.pname}";
      runtimeInputs = [
        common-updater-scripts
        curl
        yq-go
      ];
      text = ''
        feed=$(curl -fsSL ${updateFeed}/latest-mac.yml)
        version=$(yq '.version' <<< "$feed")
        sha512=$(yq '.files[] | select(.url | test("-universal\\.dmg$")) | .sha512' <<< "$feed")
        update-source-version ${finalAttrs.pname} "$version" "sha512-$sha512"
      '';
    });
  };

  meta = {
    description = "九分学长考雅机考平台";
    homepage = "https://www.9fnnn.com";
    license = lib.licenses.unfree;
    sourceProvenance =
      with lib.sourceTypes;
      [ binaryBytecode ] ++ lib.optional isDarwin binaryNativeCode;
    platforms = [
      "x86_64-linux"
      "aarch64-darwin"
    ];
    mainProgram = "jiufenxuezhang-ielts";
  };
})
