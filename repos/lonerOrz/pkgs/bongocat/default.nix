{
  lib,
  stdenv,
  fetchFromGitHub,
  rustPlatform,
  cargo-tauri,
  nodejs,
  pnpm_9,
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
  version = "0.8.1";

  src = fetchFromGitHub {
    owner = "ayangweb";
    repo = "BongoCat";
    tag = "v${finalAttrs.version}";
    hash = "sha256-UdiYws1Rsqs4SghfvYPazNwFc/K2XY0l9S94mDuY+a4=";
  };

  pnpmDeps = pnpm_9.fetchDeps {
    inherit (finalAttrs) pname version src;
    # error: pnpm.fetchDeps: `fetcherVersion` is not set
    # see https://nixos.org/manual/nixpkgs/stable/#javascript-pnpm-fetcherVersion.
    fetcherVersion = 1;
    hash = "sha256-klmImDr+/attLgspqsKeupCAbhiMlDNkJCJ6NwNYgfQ=";
  };

  cargoHash = "sha256-+I28zr8VX2G5ZWKn/0fijzsyYR+2o6SYVD3P1pi9fU8=";

  buildAndTestSubdir = "src-tauri";

  nativeBuildInputs = [
    cargo-tauri.hook
    nodejs
    pnpm_9.configHook
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
    pnpm install --frozen-lockfile
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
  };
})
