{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  fetchPnpmDeps,
  pnpmConfigHook,
  pnpmBuildHook,
  pnpm_12,
  nodejs_24,
  electron_43,
  copyDesktopItems,
  makeDesktopItem,
  makeWrapper,
  binutils,
  zip,
  zstd,
}:

let
  pnpm = pnpm_12;
  electron = electron_43;
in
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "proton-meet";
  version = "1.0.14";
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "ProtonMail";
    repo = "WebClients";
    tag = "proton-meet-desktop@${finalAttrs.version}";
    hash = "sha256-lC3f3wKYUxIybSJsPYhkXqSOLvBcbR+Wd2jBUKkirG8=";
  };

  pnpmWorkspaces = [ "proton-meet-desktop..." ];
  pnpmInstallFlags = [
    "--cpu=x64"
    "--libc=glibc"
    "--os=linux"
  ];
  prePnpmInstall = ''
    # The required Proton packages are also available from the public registry.
    rm -f .npmrc
    substituteInPlace pnpm-lock.yaml \
      --replace-fail 'https://nexus.protontech.ch/repository/web-npm-private-and-public/' \
        'https://registry.npmjs.org/'

    pnpm config set --location=project --json supportedArchitectures '{"os":["linux"],"cpu":["x64"],"libc":["glibc"]}'
    export pnpm_config_force_ignores_platform=false
    # Keep upstream's locked versions and integrity checks; skip registry policy
    # queries for unrelated applications in the monorepo's shared lockfile.
    export pnpm_config_trust_lockfile=true
  '';

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs)
      pname
      version
      src
      pnpmWorkspaces
      pnpmInstallFlags
      prePnpmInstall
      ;
    inherit pnpm;
    fetcherVersion = 5;
    hash = "sha256-jHFPv4ozHMKaJB1NFg5kkwDHl/bTwaMCu2LHoL4gx6g=";
  };

  nativeBuildInputs = [
    copyDesktopItems
    makeWrapper
    nodejs_24
    pnpm
    pnpmConfigHook
    pnpmBuildHook
    zip
  ];

  strictDeps = true;
  env = {
    CI = "1";
    ELECTRON_SKIP_BINARY_DOWNLOAD = "1";
    SENTRYCLI_SKIP_DOWNLOAD = "1";
    PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD = "1";
  };

  postPatch = ''
    substituteInPlace applications/meet-desktop/src/utils/view/viewManagement.ts \
      --replace-fail 'process.resourcesPath' "'$out/share/proton-meet'"
  '';

  pnpmBuildScript = "package";
  pnpmBuildFlags = [
    "--platform=linux"
    "--arch=x64"
  ];

  preBuild = ''
    # pnpmConfigHook already installed the selected workspaces offline.
    export pnpm_config_verify_deps_before_run=false
    export npm_config_nodedir=${electron.headers}
    # Supply Forge with Nix's Electron distribution instead of downloading one.
    substituteInPlace node_modules/@electron-forge/core-utils/dist/electron-version.js \
      --replace-fail 'return version' "return '${electron.version}'"

    cp -r ${electron.dist} electron-dist
    chmod -R u+w electron-dist
    pushd electron-dist
    zip -0Xqr ../electron.zip .
    popd
    rm -r electron-dist
    substituteInPlace node_modules/@electron/packager/dist/packager.js \
      --replace-fail 'await this.getElectronZipPath(downloadOpts)' "'$(pwd)/electron.zip'"
  '';

  nativeCheckInputs = [
    binutils
    zstd
  ];
  doCheck = true;
  checkPhase = ''
    runHook preCheck

    # SWC 1.16.13's cache loader rejects the UID-mapped sandbox root. Unpack
    # its original native module directly; the payload has a 96-byte header.
    swcAddon=node_modules/@swc/jest/node_modules/@swc/core-linux-x64-gnu/swc.linux-x64-gnu.node
    objcopy --dump-section .swc_native=swc-payload "$swcAddon"
    tail -c +97 swc-payload | zstd --decompress --stdout > "$swcAddon.unpacked"
    mv "$swcAddon.unpacked" "$swcAddon"
    rm swc-payload

    pushd applications/meet-desktop
    ../../node_modules/.bin/jest --runInBand
    popd

    runHook postCheck
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/proton-meet
    cp -r applications/meet-desktop/out/*-linux-x64/resources/. $out/share/proton-meet/
    install -Dm644 applications/meet-desktop/assets/linux/icon.png \
      $out/share/icons/hicolor/256x256/apps/proton-meet.png
    install -Dm644 applications/meet-desktop/assets/linux/icon.svg \
      $out/share/icons/hicolor/scalable/apps/proton-meet.svg

    makeWrapper ${lib.getExe electron} $out/bin/proton-meet \
      --add-flags $out/share/proton-meet/app.asar \
      --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform=auto --enable-wayland-ime=true}}" \
      --set-default ELECTRON_FORCE_IS_PACKAGED 1 \
      --set-default ELECTRON_IS_DEV 0 \
      --inherit-argv0

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "proton-meet";
      desktopName = "Proton Meet";
      exec = "proton-meet %U";
      icon = "proton-meet";
      comment = finalAttrs.meta.description;
      categories = [
        "Network"
        "VideoConference"
      ];
      mimeTypes = [ "x-scheme-handler/proton-meet" ];
    })
  ];

  meta = {
    description = "End-to-end encrypted video conferencing client";
    homepage = "https://proton.me/meet";
    downloadPage = "https://proton.me/meet/download";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ iamanaws ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "proton-meet";
  };
})
