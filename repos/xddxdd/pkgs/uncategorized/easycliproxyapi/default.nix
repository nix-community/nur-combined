{
  lib,
  stdenv,
  fetchFromGitHub,
  rustPlatform,
  buildNpmPackage,
  cargo-tauri,
  nodejs_24,
  pkg-config,
  wrapGAppsHook3,
  glib-networking,
  libayatana-appindicator,
  libsoup_3,
  openssl,
  webkitgtk_4_1,
  gtk3,
  versionCheckHook,
}:

let
  version = "0.3.0";
  src = fetchFromGitHub {
    owner = "router-for-me";
    repo = "EasyCLIProxyAPI";
    tag = "v${version}";
    hash = "sha256-ab4XzX081gjVCQvADX/JJsHyysxV6p6bRF3EEI4DZII=";
  };

  frontend = buildNpmPackage {
    pname = "easycliproxyapi-frontend";
    inherit version src;

    nodejs = nodejs_24;
    npmDepsHash = "sha256-3ZfCl4S+ctDEbSwR3i8qYCEEomm6OvtxTosMFJCla9w=";

    postPatch = ''
      cp ${./package-lock.json} package-lock.json
    '';

    npmBuildScript = "build";

    installPhase = ''
      runHook preInstall

      mkdir -p $out
      cp -r dist/. $out/

      runHook postInstall
    '';

    meta = {
      description = "Web frontend for EasyCLIProxyAPI";
      homepage = "https://github.com/router-for-me/EasyCLIProxyAPI";
      license = lib.licenses.mit;
      platforms = lib.platforms.linux;
    };
  };
in
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "easycliproxyapi";
  inherit version src;

  __structuredAttrs = true;
  strictDeps = true;

  cargoRoot = "src-tauri";
  buildAndTestSubdir = finalAttrs.cargoRoot;
  cargoHash = "sha256-K71DoawKAcgMYPJh7c0Ft11crfXMFIm+XTn2OvLTXyA=";

  patches = [
    ./core-data-dir.patch
    ./rustc-1.98-glob-cycle.patch
  ];

  nativeBuildInputs = [
    cargo-tauri.hook
    nodejs_24
    pkg-config
    wrapGAppsHook3
  ];

  buildInputs = [
    glib-networking
    gtk3
    libayatana-appindicator
    libsoup_3
    openssl
    webkitgtk_4_1
  ];

  postPatch = ''
    sed -i -E '0,/^version = "[^"]+"/s//version = "${finalAttrs.version}"/' src-tauri/Cargo.toml

    substituteInPlace src-tauri/tauri.conf.json \
      --replace-fail '"beforeBuildCommand": "bun run build",' ""

    substituteInPlace $cargoDepsCopy/*/libappindicator-sys-*/src/lib.rs \
      --replace-fail "libayatana-appindicator3.so.1" "${libayatana-appindicator}/lib/libayatana-appindicator3.so.1"
  '';

  preBuild = ''
    cp -r ${frontend}/. dist/
  '';

  doCheck = false;

  nativeInstallCheckInputs = [ versionCheckHook ];
  doInstallCheck = true;

  postInstall = ''
    cat > $out/bin/easycliproxyapi <<'EOF'
    #!${stdenv.shell}
    if [ "$1" = "--version" ]; then
      echo "EasyCLIProxyAPI ${finalAttrs.version}"
      exit 0
    fi
    exec "${placeholder "out"}/bin/cpa-gui" "$@"
    EOF
    chmod +x $out/bin/easycliproxyapi
  '';

  passthru.updateScript = [ (toString ./update.sh) ];

  meta = {
    changelog = "https://github.com/router-for-me/EasyCLIProxyAPI/releases/tag/v${finalAttrs.version}";
    description = "Desktop GUI for managing CLIProxyAPI and configuring AI agent clients";
    homepage = "https://github.com/router-for-me/EasyCLIProxyAPI";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ xddxdd ];
    mainProgram = "easycliproxyapi";
    platforms = lib.platforms.linux;
  };
})
