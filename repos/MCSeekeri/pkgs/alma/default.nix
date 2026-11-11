{
  lib,
  stdenv,
  fetchurl,
  dpkg,
  makeWrapper,
  wrapBuddy,
  alsa-lib,
  atk,
  cairo,
  ffmpeg,
  fontconfig,
  fcitx5-gtk,
  gdk-pixbuf,
  glib,
  gtk-layer-shell,
  gtk3,
  harfbuzz,
  libappindicator-gtk3,
  libepoxy,
  libpulseaudio,
  libsecret,
  libx11,
  libxtst,
  pango,
  webkitgtk_4_1,
  cacert,
  xdg-utils,
  nix-update-script,
}:

let
  runtimeLibs = [
    gtk3
    webkitgtk_4_1
    glib
    atk
    pango
    cairo
    gdk-pixbuf
    harfbuzz
    fontconfig
    libsecret
    libappindicator-gtk3
    gtk-layer-shell
    libepoxy
    libx11
    libxtst
    alsa-lib
    libpulseaudio
    ffmpeg
  ];

  canRunHostTools = stdenv.buildPlatform.canExecute stdenv.hostPlatform;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "alma";
  version = "0.4.567";

  src = fetchurl {
    url = "https://github.com/yetone/alma-releases/releases/download/v${finalAttrs.version}/alma-${finalAttrs.version}-linux-${
      if stdenv.hostPlatform.isAarch64 then "arm64" else "amd64"
    }.deb";
    hash =
      if stdenv.hostPlatform.isAarch64 then
        "sha256-qPUYeOghXzkiN8bjIoTGt7MQOfllWJKBvIxq8AKL+8c="
      else
        "sha256-uDkhHCq2Lib0ffEbWrN4mKnXIHfd4Jthg48SNmEE6Qk=";
  };

  nativeBuildInputs = [
    dpkg
    makeWrapper
    wrapBuddy
  ]
  ++ lib.optional canRunHostTools gtk3.dev;

  buildInputs = runtimeLibs ++ [ stdenv.cc.cc.lib ];

  runtimeDependencies = runtimeLibs;

  dontConfigure = true;
  dontBuild = true;
  dontStrip = true;

  unpackPhase = ''
    runHook preUnpack

    mkdir -p build
    dpkg-deb -x $src build

    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/opt $out/bin $out/share
    cp -r build/opt/alma $out/opt/alma

    find $out/opt/alma -name '*.musl.node' -delete

    rm $out/opt/alma/alma-server/runtime/node
    restoreNodeLink() {
      ln -s alma-server $out/opt/alma/alma-server/runtime/node
    }
    postFixupHooks+=(restoreNodeLink)

    install -Dm644 build/usr/share/applications/alma.desktop \
      $out/share/applications/alma.desktop
    substituteInPlace $out/share/applications/alma.desktop \
      --replace-fail "Exec=/opt/alma/alma" "Exec=alma"

    cp -r build/usr/share/icons $out/share/icons

    ${lib.optionalString canRunHostTools ''
      mkdir -p $out/etc/gtk-3.0
      ${gtk3.dev}/bin/gtk-query-immodules-3.0 \
        ${gtk3}/lib/gtk-3.0/3.0.0/immodules/*.so \
        ${fcitx5-gtk}/lib/gtk-3.0/3.0.0/immodules/im-fcitx5.so \
        > $out/etc/gtk-3.0/immodules.cache
    ''}

    makeWrapper $out/opt/alma/alma $out/bin/alma \
      --suffix PATH : ${lib.makeBinPath [ xdg-utils ]} \
      --set-default SSL_CERT_FILE "${cacert}/etc/ssl/certs/ca-bundle.crt" \
      --set GSETTINGS_SCHEMA_DIR "${gtk3}/share/gsettings-schemas/${gtk3.name}/glib-2.0/schemas" \
      --set GDK_PIXBUF_MODULE_FILE "${gdk-pixbuf}/lib/gdk-pixbuf-2.0/2.10.0/loaders.cache" \
      --prefix XDG_DATA_DIRS : "${gtk3}/share/gsettings-schemas/${gtk3.name}" \
      --prefix GTK_PATH : "${fcitx5-gtk}/lib/gtk-3.0" \
      ${lib.optionalString canRunHostTools "--set GTK_IM_MODULE_FILE \"$out/etc/gtk-3.0/immodules.cache\""}

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "GUI client for herdr and AI agent harness";
    longDescription = ''
      Alma is an AI agent harness and the desktop/mobile GUI client for herdr.
      It runs Claude Code, Codex and pi agents as clean conversations, bundles
      its own browser, skills, MCP support and local-first storage.
    '';
    homepage = "https://alma.now";
    changelog = "https://github.com/yetone/alma-releases/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.unfree;
    mainProgram = "alma";
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [ MCSeekeri ];
  };
})
