{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchPnpmDeps,
  rustPlatform,
  cargo-tauri,
  nodejs,
  pnpm_9,
  pnpmConfigHook,
  pkg-config,
  systemd,
  libayatana-appindicator,
  glib,
  gtk3,
  webkitgtk_4_1,
  wrapGAppsHook3,
  glib-networking,
  cacert,
  libXtst,
  xdg-utils,
  jq,
  makeWrapper,
  writableTmpDirAsHomeHook,
  makeDesktopItem,
  copyDesktopItems,
}:
let
  gappsWrapper = lib.optionalString stdenv.hostPlatform.isLinux "''\${gappsWrapperArgs[@]}";
in
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "bongocat";
  version = "0.9.0";

  src = fetchFromGitHub {
    owner = "ayangweb";
    repo = "BongoCat";
    tag = "v${finalAttrs.version}";
    hash = "sha256-VP1vCEF5OBGU2/XJ0LiuaiPSaAzWyGUpne0J3ZEI7xM=";
  };

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs)
      pname
      version
      src
      ;
    pnpm = pnpm_9;
    fetcherVersion = 3;
    hash = "sha256-O8vhpMapWJSLj/7W/jdstOnsXJWTdUTpG/4RXcUb+og=";
    extraPrefetchArgs = [
      "--no-frozen-lockfile"
    ];
  };

  cargoHash = "sha256-sELFENGhImyxo0Q0UEsrjGFjk0G8tBBNBVCwLX7dW7g=";

  buildAndTestSubdir = "src-tauri";

  nativeBuildInputs = [
    cargo-tauri.hook
    nodejs
    pnpm_9
    pnpmConfigHook
    pkg-config
    xdg-utils
    jq
    makeWrapper
    writableTmpDirAsHomeHook
    copyDesktopItems
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    wrapGAppsHook3
  ];

  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    glib-networking
    glib
    gtk3
    webkitgtk_4_1
    libayatana-appindicator
    cacert
    libXtst
    systemd
  ];

  postPatch = ''
    jq '.bundle.createUpdaterArtifacts = false' src-tauri/tauri.conf.json \
      > tmp.json && mv tmp.json src-tauri/tauri.conf.json
  '';

  preBuild = ''
    pnpm install --no-frozen-lockfile
    pnpm run build:icon
    pnpm run build:vite
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "${finalAttrs.pname}";
      exec = "bongocat";
      icon = "bongocat";
      desktopName = "BongoCat";
      comment = "Desktop mascot app featuring animated cat drummer";
      categories = [ "Utility" ];
    })
  ];

  installPhase = ''
    runHook preInstall

    install -Dm755 target/${stdenv.hostPlatform.config}/release/bongo-cat $out/libexec/bongocat
    install -Dm644 src-tauri/icons/32x32.png $out/share/icons/hicolor/32x32/apps/bongocat.png

    mkdir -p $out/usr/lib/BongoCat/assets
    cp -r src-tauri/assets/* $out/usr/lib/BongoCat/assets/

    makeWrapper $out/libexec/bongocat $out/bin/bongocat \
      ${gappsWrapper} \
      --set APPDIR $out \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ libayatana-appindicator ]}

    runHook postInstall
  '';

  dontWrapGApps = true;

  meta = {
    description = "Desktop mascot app featuring animated cat drummer";
    homepage = "https://github.com/ayangweb/BongoCat";
    mainProgram = "bongocat";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    binaryNativeCode = true;
    broken = true; # 上游 rust 和 pnpm 的依赖版本不一致,我真的很讨厌修改lock文件的版本
  };
})
