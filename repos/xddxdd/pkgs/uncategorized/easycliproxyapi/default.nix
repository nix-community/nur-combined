{
  lib,
  stdenv,
  aws-lc,
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
  sqlite,
  webkitgtk_4_1,
  gtk3,
  versionCheckHook,
}:

let
  version = "0.3.101";
  src = fetchFromGitHub {
    owner = "router-for-me";
    repo = "EasyCLIProxyAPI";
    tag = "v${version}";
    hash = "sha256-b07O5jhHscgpJ241/umyVP6g8wG7v2+fPwYNsRZ2HsI=";
  };

  frontend = buildNpmPackage {
    pname = "easycliproxyapi-frontend";
    inherit version src;

    nodejs = nodejs_24;
    npmDepsHash = "sha256-y9OWnIfqSkgDCA6jvk69J2nSf4oWZ/dmAsk/KeTfxqM=";

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
  cargoHash = "sha256-sdrWw8w8Y2YETgjIGg5wKDOA5n8zgffvCZ3pUrnjNM0=";

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
    aws-lc
    glib-networking
    gtk3
    libayatana-appindicator
    libsoup_3
    openssl
    sqlite
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
