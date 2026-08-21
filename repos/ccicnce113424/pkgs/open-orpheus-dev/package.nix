{
  lib,
  stdenv,
  fetchFromGitHub,
  pnpm_11,
  fetchPnpmDeps,
  pnpmConfigHook,
  nodejs,
  electron_43,
  rustPlatform,
  cargo,
  rustc,
  wasm-bindgen-cli_0_2_126,
  zip,
  makeWrapper,
  copyDesktopItems,
  makeDesktopItem,
  removeReferencesTo,
  nix-update-script,
}:
let
  pnpm = pnpm_11;
  electron = electron_43;
  wasm-bindgen-cli = wasm-bindgen-cli_0_2_126;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "open-orpheus";
  version = "0.16.2";
  src = fetchFromGitHub {
    owner = "YUCLing";
    repo = "open-orpheus";
    tag = "v${finalAttrs.version}";
    hash = "sha256-mijFHclTLj/we40qKAze3fiI06srnqWFA91VzXXPz38=";
  };

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs)
      pname
      version
      src
      ;
    inherit pnpm;
    fetcherVersion = 4;
    hash = "sha256-OzfljUkT9mX1M0sReoTBxhn+ezzI5PDp0s/XA56nUrs=";
  };

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs)
      pname
      version
      src
      ;
    hash = "sha256-3cfN+EKFVk4jaXTyn8MkO3l3mQiNzXBdGO7+OaFp5Uw=";
  };

  nativeBuildInputs = [
    pnpmConfigHook
    pnpm
    nodejs
    rustPlatform.cargoSetupHook
    cargo
    rustc
    rustc.llvmPackages.lld
    wasm-bindgen-cli
    zip
    makeWrapper
    copyDesktopItems
    removeReferencesTo
  ];

  strictDeps = true;
  __structuredAttrs = true;

  env = {
    ELECTRON_SKIP_BINARY_DOWNLOAD = "1";
    # electron-forge's console output is squeezed into one narrow column if unset
    CI = "1";
  };

  buildPhase = ''
    runHook preBuild

    export npm_config_nodedir=${electron.headers}

    # override the detected electron version
    substituteInPlace node_modules/@electron-forge/core-utils/dist/electron-version.js \
      --replace-fail "return version" "return '${electron.version}'"

    # create the electron archive to be used by electron-packager
    cp -r ${electron.dist} electron-dist
    chmod -R u+w electron-dist

    pushd electron-dist
    zip -0Xqr ../electron.zip .
    popd

    rm -r electron-dist

    # force @electron/packager to use our electron instead of downloading it
    substituteInPlace node_modules/@electron/packager/dist/packager.js \
      --replace-fail "await this.getElectronZipPath(downloadOpts)" "'$(pwd)/electron.zip'"

    pnpm build:modules

    pnpm make \
      --arch "${stdenv.hostPlatform.node.arch}" \
      --platform "${stdenv.hostPlatform.node.platform}" \
      --targets "@electron-forge/maker-zip"

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    install -D assets/icon.svg $out/share/icons/hicolor/scalable/apps/open-orpheus.svg
    _icon_sizes=(256 512)
    for _icons in "''${_icon_sizes[@]}";do
      install -D assets/icon_''${_icons}.png $out/share/icons/hicolor/''${_icons}x''${_icons}/apps/open-orpheus.png
    done

    # remove references to nodejs
    find out/*/resources{,.pak} -type f -exec remove-references-to -t ${nodejs} '{}' \;

    _sharedir=$out/share/open-orpheus
    mkdir -p $_sharedir
    cp -r out/*/resources{,.pak} $_sharedir

    makeWrapper ${lib.getExe electron} "$out/bin/open-orpheus" \
      --add-flag $_sharedir/resources/app.asar \
      --set ELECTRON_FORCE_IS_PACKAGED 1 \
      --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime=true}}" \
      --inherit-argv0

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "open-orpheus";
      desktopName = "Open Orpheus";
      comment = "An open-source Netease Cloud Music client";
      genericName = "open-orpheus";
      exec = "open-orpheus %U";
      icon = "open-orpheus";
      type = "Application";
      startupNotify = false;
      categories = [
        "AudioVideo"
        "Audio"
        "Network"
      ];
      startupWMClass = "open-orpheus";
      mimeTypes = [ "x-scheme-handler/orpheus" ];
      extraConfig.X-KDE-Protocols = "orpheus";
    })
  ];

  passthru.updateScript = nix-update-script { extraArgs = [ "--use-github-releases" ]; };

  meta = {
    description = "Open-source Netease Cloud Music client";
    homepage = "https://github.com/YUCLing/open-orpheus";
    changelog = "https://github.com/YUCLing/open-orpheus/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ccicnce113424 ];
    mainProgram = "open-orpheus";
    platforms = lib.platforms.linux;
  };
})
