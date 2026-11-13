{
  lib,
  stdenv,
  callPackage,
  _7zz,
  copyDesktopItems,
  electron_41,
  libicns,
  makeDesktopItem,
  makeWrapper,

  sources,
  source ? sources.jiufenxuezhang-ielts,
}:

let
  # Pinned: callPackage would otherwise inject the top-level `electron` (newer V8
  # API) and the prebuilt native addon does not compile against it.
  electron = electron_41;

  inherit (stdenv.hostPlatform) isDarwin isLinux;

  appName = "九分学长考雅机考平台";
in
stdenv.mkDerivation (finalAttrs: {
  inherit (source) pname version src;

  __structuredAttrs = true;
  strictDeps = true;

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

  # Must be built against the same Electron that runs the app.
  passthru.better-sqlite3-mc = callPackage ./better-sqlite3-multiple-ciphers.nix {
    inherit electron;
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
