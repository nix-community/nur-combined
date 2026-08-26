{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  dpkg,
  makeWrapper,
  wrapGAppsHook3,
  cacert,
  nodejs_24,
  git,
  xdg-utils,
  alsa-lib,
  at-spi2-atk,
  cups,
  gtk3,
  libdrm,
  libgbm,
  libnotify,
  libsecret,
  libuuid,
  libx11,
  libxcb,
  libxcomposite,
  libxdamage,
  libxext,
  libxfixes,
  libxkbcommon,
  libxrandr,
  libXScrnSaver,
  libxshmfence,
  libxtst,
  mesa,
  nspr,
  nss,
  systemd,
}:

let
  sources = {
    x86_64-linux = {
      debArch = "amd64";
      hash = "sha256-EgYNGDwX0BiHGQ/GWSF2xnYyrRCP8SZW0JZVwvydSTU=";
    };
    aarch64-linux = {
      debArch = "arm64";
      hash = "sha256-/ljXy5IieOB/00OaiCnzG4dAh3DZlxBeo4XzGHI5vTw=";
    };
  };
  source =
    sources.${stdenv.hostPlatform.system} or {
      debArch = "unsupported";
      hash = lib.fakeHash;
    };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "open-knowledge";
  version = "0.63.6";

  src = fetchurl {
    url = "https://github.com/inkeep/open-knowledge/releases/download/v${finalAttrs.version}/OpenKnowledge-${source.debArch}.deb";
    inherit (source) hash;
  };

  nativeBuildInputs = [
    autoPatchelfHook
    dpkg
    makeWrapper
    wrapGAppsHook3
  ];

  buildInputs = [
    alsa-lib
    at-spi2-atk
    cups
    gtk3
    libdrm
    libgbm
    libnotify
    libsecret
    libuuid
    libxkbcommon
    libXScrnSaver
    libxshmfence
    mesa
    nspr
    nss
    systemd
    libx11
    libxcb
    libxcomposite
    libxdamage
    libxext
    libxfixes
    libxrandr
    libxtst
  ];

  runtimeDependencies = [ libsecret ];

  gappsWrapperArgs = [
    "--prefix"
    "PATH"
    ":"
    (lib.makeBinPath [
      git
      xdg-utils
    ])
    "--set"
    "SSL_CERT_FILE"
    "${cacert}/etc/ssl/certs/ca-bundle.crt"
    "--set"
    "SSL_CERT_DIR"
    "${cacert}/etc/ssl/certs"
  ];

  unpackPhase = ''
    runHook preUnpack
    dpkg-deb --extract "$src" .
    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/lib" "$out/bin" "$out/share"
    mv opt/OpenKnowledge "$out/lib/open-knowledge"
    mv usr/share/applications usr/share/icons "$out/share/"

    substituteInPlace "$out/share/applications/openknowledge.desktop" \
      --replace-fail "/opt/OpenKnowledge/openknowledge" "openknowledge"

    makeWrapper "$out/lib/open-knowledge/openknowledge" "$out/bin/openknowledge" \
      --add-flags "--disable-setuid-sandbox"
    makeWrapper ${nodejs_24}/bin/node "$out/bin/ok" \
      --add-flags "$out/lib/open-knowledge/resources/cli/dist/cli.mjs"
    ln -s ok "$out/bin/open-knowledge"

    runHook postInstall
  '';

  meta = {
    description = "AI-native Markdown editor and LLM wiki";
    homepage = "https://github.com/inkeep/open-knowledge";
    changelog = "https://github.com/inkeep/open-knowledge/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ mrene ];
    mainProgram = "openknowledge";
    platforms = builtins.attrNames sources;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
  };
})
