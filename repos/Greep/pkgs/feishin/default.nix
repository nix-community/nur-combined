{
  lib,
  stdenv,
  buildNpmPackage,
  fetchFromGitHub,
  electron_43,
  mpv-unwrapped,
  fetchPnpmDeps,
  pnpmConfigHook,
  pnpm_11,
  nodejs-slim_latest,
  darwin,
  actool,
  copyDesktopItems,
  makeDesktopItem,
  nix-update-script,
  maintainers
}:
let
  electron = electron_43;

  # Fix pnpm issue on darwin https://github.com/NixOS/nixpkgs/issues/525627
  pnpm = pnpm_11.override { nodejs-slim = nodejs-slim_latest; };
in
buildNpmPackage (finalAttrs: {
  pname = "feishin";
  version = "1.17.0";

  src = fetchFromGitHub {
    owner = "jeffvli";
    repo = "feishin";
    tag = "v${finalAttrs.version}";
    hash = "sha256-1ZIw5XiN+2EhpHmdvN0HxgMSvn4QvN9B+ZJ3RlPXhLw=";
  };

  __structuredAttrs = true;

  npmConfigHook = pnpmConfigHook;
  npmBuildScript = "build";

  npmDeps = null;
  pnpmDeps = fetchPnpmDeps {
    inherit pnpm;
    inherit (finalAttrs)
      pname
      version
      src
      ;
    fetcherVersion = 4;
    hash = "sha256-ltpz4e5Vv2vxt/93M4+vHUFJZjwTRwb2zrwvl1Lqjo8=";
  };

  env.ELECTRON_SKIP_BINARY_DOWNLOAD = "1";

  nativeBuildInputs = [
    pnpm
    copyDesktopItems
  ]
  ++ lib.optionals (stdenv.hostPlatform.isDarwin) [
    darwin.autoSignDarwinBinariesHook
    actool
  ];

  postPatch = ''
    # release/app dependencies are installed on preConfigure
    substituteInPlace package.json \
      --replace-fail '"postinstall": "install-electron && electron-builder install-app-deps",' ""
  '';

  postBuild = ''
    cp -r ${electron.dist} electron-dist
    chmod -R u+w electron-dist

    npm exec electron-builder -- \
      --dir \
      -c.electronDist=electron-dist \
      -c.electronVersion=${electron.version} \
      -c.npmRebuild=false \
      ${lib.optionalString stdenv.hostPlatform.isDarwin "-c.mac.identity=null"}
  '';

  installPhase = ''
    runHook preInstall
  ''
  + lib.optionalString (stdenv.hostPlatform.isDarwin) ''
    mkdir -p $out/{Applications,bin}
    cp -r dist/**/Feishin.app $out/Applications/
    makeWrapper $out/Applications/Feishin.app/Contents/MacOS/Feishin $out/bin/feishin \
      --prefix PATH : "${lib.makeBinPath [ mpv-unwrapped ]}" \
      --set DISABLE_AUTO_UPDATES 1
  ''
  + lib.optionalString (stdenv.hostPlatform.isLinux) ''
    mkdir -p $out/share/feishin

    pushd dist/*-unpacked/
    cp -r locales resources{,.pak} $out/share/feishin
    popd

    # Code relies on checking app.isPackaged, which returns false if the executable is electron.
    # Set ELECTRON_FORCE_IS_PACKAGED=1.
    # https://github.com/electron/electron/issues/35153#issuecomment-1202718531
    makeWrapper ${lib.getExe electron} $out/bin/feishin \
      --prefix PATH : "${lib.makeBinPath [ mpv-unwrapped ]}" \
      --add-flags $out/share/feishin/resources/app.asar \
      --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime=true}}" \
      --set ELECTRON_FORCE_IS_PACKAGED 1 \
      --set DISABLE_AUTO_UPDATES 1 \
      --inherit-argv0

    install -Dm644 org.jeffvli.feishin.metainfo.xml $out/share/metainfo/org.jeffvli.feishin.metainfo.xml

    for size in 32 64 128 256 512 1024; do
      mkdir -p $out/share/icons/hicolor/"$size"x"$size"/apps
      ln -s \
        $out/share/feishin/resources/assets/icons/"$size"x"$size".png \
        $out/share/icons/hicolor/"$size"x"$size"/apps/feishin.png
    done
    runHook postInstall
  '';

  desktopItems = makeDesktopItem {
    name = "feishin";
    desktopName = "Feishin";
    comment = "Full-featured Jellyfin, Navidrome, and OpenSubsonic Compatible Music Player";
    icon = "feishin";
    exec = "feishin %u";
    categories = [
      "Audio"
      "AudioVideo"
      "Player"
      "Music"
    ];
    mimeTypes = [ "x-scheme-handler/feishin" ];
  };

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = with lib; {
    description = "Full-featured Jellyfin, Navidrome, and OpenSubsonic Compatible Music Player";
    homepage = "https://github.com/jeffvli/feishin";
    changelog = "https://github.com/jeffvli/feishin/releases/tag/v${finalAttrs.version}";
    sourceProvenance = with sourceTypes; [ fromSource ];
    license = licenses.gpl3Plus;
    platforms = platforms.unix;
    mainProgram = "feishin";
    maintainers = with maintainers; [ greep ];
  };
})