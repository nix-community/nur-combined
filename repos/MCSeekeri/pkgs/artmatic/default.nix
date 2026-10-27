{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchPnpmDeps,
  pnpmConfigHook,
  pnpm_12,
  nodejs,
  electron,
  makeWrapper,
  makeDesktopItem,
  copyDesktopItems,
  desktopToDarwinBundle,
  nix-update-script,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "artmatic";
  version = "0.3.0-unstable-2026-10-27";

  src = fetchFromGitHub {
    owner = "OxygenNine";
    repo = "artmatic";
    rev = "e5aa2db9ab4e75993cf769495f5e95cc2a1f40d8";
    hash = "sha256-vcaxOmpWDXuvXkfUyhduSmB2bGcAcfAWdIdto+xjv6M=";
  };

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    pnpm = pnpm_12;
    fetcherVersion = 4;
    hash =
      if stdenv.hostPlatform.isDarwin then
        "sha256-tg5ikO+NYfiFnLa2Go7/P5h1pnXyCkHI3c1iNnTYjbE="
      else
        "sha256-/W7oQWINOX7C7gjLKWc/eixi1jM6pCGMthOmm62aAAs=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    nodejs
    pnpmConfigHook
    pnpm_12
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

  buildPhase = ''
    runHook preBuild

    pnpm run build

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
      name = "artmatic";
      desktopName = "Artmatic";
      comment = "Open-source editor for algorithmic art and glitch art";
      exec = "artmatic %U";
      icon = "artmatic";
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
})
