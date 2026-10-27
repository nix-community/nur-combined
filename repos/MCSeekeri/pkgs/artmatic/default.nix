{
  lib,
  stdenv,
  fetchFromGitHub,
  bun,
  cacert,
  nodejs,
  electron,
  makeWrapper,
  makeDesktopItem,
  copyDesktopItems,
  desktopToDarwinBundle,
  nix-update-script,
  writableTmpDirAsHomeHook,
}:

let
  pname = "artmatic";
  version = "0.3.0-unstable-2026-10-26";

  src = fetchFromGitHub {
    owner = "OxygenNine";
    repo = "artmatic";
    rev = "8f57ede70392dbb92a0cccfb82e30b45a0f1329c";
    hash = "sha256-KczBBzbx+TLEK4Fw4ctwULUgXTrECWB3Z2Ew5TvGk0s=";
  };

  node_modules = stdenv.mkDerivation {
    pname = "${pname}-node_modules";
    inherit version src;

    nativeBuildInputs = [
      bun
      cacert
      writableTmpDirAsHomeHook
    ];

    dontConfigure = true;

    buildPhase = ''
      runHook preBuild

      export SSL_CERT_FILE=${cacert}/etc/ssl/certs/ca-bundle.crt
      export BUN_INSTALL_CACHE_DIR=$(mktemp -d)
      bun install \
        --backend=copyfile \
        --cafile=${cacert}/etc/ssl/certs/ca-bundle.crt \
        --cpu="*" \
        --frozen-lockfile \
        --ignore-scripts \
        --no-progress \
        --os="*"

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p $out
      cp -R node_modules $out

      runHook postInstall
    '';

    dontFixup = true;
    outputHash = "sha256-+Qusl+2hxvJ2b1symFzuNMhD84ooKCKU1eCL2xfxPOM=";
    outputHashMode = "recursive";
  };
in
stdenv.mkDerivation {
  inherit pname version src;

  strictDeps = true;

  nativeBuildInputs = [
    nodejs
    makeWrapper
    copyDesktopItems
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [ desktopToDarwinBundle ];

  env = {
    ELECTRON_SKIP_BINARY_DOWNLOAD = "1";
    PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD = "1";
  };

  postPatch = ''
    substituteInPlace desktop/main.mjs \
      --replace-fail "path.join(__dirname, '..', '.tmp-electron')" \
                     "path.join(app.getPath('appData'), 'artmatic')"
    substituteInPlace desktop/main.mjs \
      --replace-fail "async function main() {" "async function main() {
      if (process.platform !== 'darwin') require('electron').Menu.setApplicationMenu(null)"
  '';

  configurePhase = ''
    runHook preConfigure

    cp -R ${node_modules}/. .
    patchShebangs node_modules

    runHook postConfigure
  '';

  buildPhase = ''
    runHook preBuild

    npm run build

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    appDir=$out/share/artmatic
    install -d "$appDir/dist" "$appDir/scripts"
    cp -R dist/. "$appDir/dist/"
    install -m644 desktop/main.mjs desktop/host.mjs desktop/preload.cjs "$appDir/"
    install -m644 scripts/capacity.mjs "$appDir/scripts/"

    makeWrapper ${lib.getExe electron} $out/bin/artmatic \
      ${lib.optionalString stdenv.hostPlatform.isLinux ''--add-flags "--class=artmatic"''} \
      --add-flags "$appDir/main.mjs" \
      --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime=true}}"

    install -Dm644 src/assets/brand/artmatic-small-light.svg \
      $out/share/icons/hicolor/scalable/apps/artmatic.svg

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      name = pname;
      desktopName = "Artmatic";
      comment = "Open-source editor for algorithmic art and glitch art";
      exec = "artmatic %U";
      icon = pname;
      terminal = false;
      categories = [
        "AudioVideo"
        "Graphics"
      ];
      startupWMClass = "artmatic";
    })
  ];

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  meta = {
    description = "Web-native open-source editing software for algorithmic art and glitch art";
    longDescription = ''
      Artmatic is a web-native video editor aimed at algorithmic and glitch art.
      It ships a timeline, keyframe curves, cellular-automaton and fractal
      generators, glitch effects, gl-transitions, typography compositing, audio
      with BPM detection, and MP4/PNG/GIF export. This package wraps the bundled
      web app in an Electron shell so it runs as a desktop application with
      local file access.
    '';
    homepage = "https://github.com/OxygenNine/artmatic";
    license = lib.licenses.asl20;
    mainProgram = "artmatic";
    platforms = electron.meta.platforms;
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
    maintainers = with lib.maintainers; [ MCSeekeri ];
  };
}
