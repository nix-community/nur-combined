{
  lib,
  stdenvNoCC,
  rustPlatform,
  fetchFromGitHub,
  cargo-tauri,
  bun,
  nodejs,
  pkg-config,
  wrapGAppsHook3,
  glib-networking,
  openssl,
  webkitgtk_4_1,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "vaccfr-installer";
  version = "0.2.0";
  # Upstream tags releases by AIRAC cycle, not by installer version.
  tag = "2610_1";

  src = fetchFromGitHub {
    owner = "vaccfr";
    repo = "Sector-Files";
    tag = finalAttrs.tag;
    sparseCheckout = [ "installer" ];
    hash = "sha256-r1P7XM2x/KUMtCDlb/FmPg51Sq4mVn9NCQIAqTJMsws=";
  };

  sourceRoot = "${finalAttrs.src.name}/installer";

  cargoHash = "sha256-p+xbgoAJF8lVGZWbNpC2/5rAF4LrqhwBvTiETD0s5h8=";

  # bun installs only the native optional deps (rollup, lightningcss, tailwind oxide)
  # for the build platform, so this hash is per-system.
  bunDeps = stdenvNoCC.mkDerivation {
    pname = "${finalAttrs.pname}-bun-deps";
    inherit (finalAttrs) version src sourceRoot;
    nativeBuildInputs = [ bun ];
    dontConfigure = true;
    buildPhase = ''
      runHook preBuild
      export HOME=$TMPDIR
      bun install --frozen-lockfile --no-progress --ignore-scripts
      runHook postBuild
    '';
    installPhase = ''
      runHook preInstall
      cp -r node_modules $out
      runHook postInstall
    '';
    dontFixup = true;
    outputHashMode = "recursive";
    outputHashAlgo = "sha256";
    outputHash = "sha256-S7qMWtNn0jb61G+dqoQCx4NPww75LQRrdbC10YLx7c0=";
  };

  nativeBuildInputs = [
    cargo-tauri.hook
    bun
    nodejs
    pkg-config
    wrapGAppsHook3
  ];

  buildInputs = [
    glib-networking
    openssl
    webkitgtk_4_1
  ];

  preBuild = ''
    cp -r ${finalAttrs.bunDeps} node_modules
    chmod -R u+w node_modules
    patchShebangs node_modules
    export HOME=$TMPDIR
  '';

  buildAndTestSubdir = "src-tauri";

  tauriBuildFlags = [
    "--config"
    # Upstream signs updater artifacts in CI; without TAURI_SIGNING_PRIVATE_KEY the bundler aborts.
    ''{"bundle":{"createUpdaterArtifacts":false}}''
  ];

  doCheck = false;

  meta = {
    description = "Installer and updater for the French vACC controller pack (EuroScope sector files)";
    homepage = "https://github.com/vaccfr/Sector-Files/tree/main/installer";
    changelog = "https://github.com/vaccfr/Sector-Files/releases/tag/${finalAttrs.tag}";
    license = lib.licenses.unfree; # upstream repository ships no license
    platforms = [ "x86_64-linux" ];
    mainProgram = "controller-pack-installer";
  };
})
