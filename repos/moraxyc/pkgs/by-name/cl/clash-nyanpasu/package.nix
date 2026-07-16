{
  lib,
  stdenv,
  fetchurl,
  atk,
  cairo,
  cargo-tauri,
  clash-rs,
  dart-sass,
  dbus,
  fetchPnpmDeps,
  gdk-pixbuf,
  glib,
  glib-networking,
  gtk3,
  jq,
  libayatana-appindicator,
  librsvg,
  meta-rules-dat,
  mihomo,
  moreutils,
  nodejs,
  nyanpasu-service,
  pango,
  pkg-config,
  pnpmConfigHook,
  pnpm_11,
  rustPlatform,
  webkitgtk_4_1,
  wrapGAppsHook4,
  xdotool,
  yq-go,
  zstd,

  enableLTO ? false,

  sources,
  source ? sources.clash-nyanpasu,
}:

let
  pnpm = pnpm_11;
  vendorSources = import ./sources.nix fetchurl;
in
rustPlatform.buildRustPackage (finalAttrs: {
  inherit (source) pname version src;
  __structuredAttrs = true;
  strictDeps = true;

  patches = [
    ./fix-local-inlang-plugins.patch
    ./fix-nyanpasu-utils-package-entry.patch
  ];

  cargoRoot = "backend";
  buildAndTestSubdir = finalAttrs.cargoRoot;

  cargoDeps =
    let
      originalCargoDeps = rustPlatform.importCargoLock source.cargoLock."backend/Cargo.lock";
      patchedCargoDeps = originalCargoDeps.overrideAttrs (old: {
        buildCommand = lib.replaceString ''ln -s "$crate" $out/$(basename "$crate" | cut -c 34-)'' ''
          dest="$out/$(basename "$crate" | cut -c 34-)"

          if [ -e "$dest" ]; then
            echo "importCargoLock: duplicate crate vendor path: $dest" >&2
            if [ -e "$dest/.cargo-config" ] && [ ! -e "$crate/.cargo-config" ]; then
              echo "  replacing existing git crate with registry crate" >&2
              ln -sfnT "$crate" "$dest"
            else
              echo "  keeping existing crate" >&2
            fi
          else
            ln -s "$crate" "$dest"
          fi
        '' old.buildCommand;
      });
    in
    patchedCargoDeps;

  # nix-update auto
  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs)
      pname
      version
      src
      patches
      ;
    inherit pnpm;
    fetcherVersion = 4;
    hash = "sha256-6rv5WOI2EVUUZpQh+G2rWJDb27kTNl2EQd7UUvOWpXI=";
  };

  nativeBuildInputs = [
    cargo-tauri.hook
    dart-sass
    jq
    moreutils
    nodejs
    pkg-config
    pnpm
    pnpmConfigHook
    wrapGAppsHook4
    yq-go
  ];

  buildInputs = [
    zstd
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    atk
    cairo
    dbus
    gdk-pixbuf
    glib
    glib-networking
    gtk3
    libayatana-appindicator
    librsvg
    pango
    webkitgtk_4_1
    xdotool
  ];

  env = {
    # nightly features
    RUSTC_BOOTSTRAP = 1;

    ZSTD_SYS_USE_PKG_CONFIG = true;
  };

  postPatch = ''
    yq -i -p toml -o toml '.profile.release.lto = ${lib.boolToString enableLTO}' backend/Cargo.toml

    # Tauri
    jq '
      .bundle.createUpdaterArtifacts = false |
      .build.beforeBuildCommand = "true" |
      del(.bundle.resources) |
      del(.bundle.externalBin)
    ' backend/tauri/tauri.conf.json | sponge backend/tauri/tauri.conf.json

    # Reproducibility
    substituteInPlace backend/tauri/build.rs \
      --replace-fail \
        'let build_date = Utc::now().to_rfc3339_opts(SecondsFormat::Millis, true);' \
        'let build_date = DateTime::<Utc>::from_timestamp(std::env::var("SOURCE_DATE_EPOCH").ok().and_then(|v| v.parse().ok()).unwrap_or(1), 0).unwrap().to_rfc3339_opts(SecondsFormat::Millis, true);'

    # boa_utils vendor
    mkdir -p backend/boa_utils/src/module/builtin/vendor
    replace_args=(--replace-fail 'include_url_bytes_with_brotli!' 'include_bytes_brotli!')
    ${lib.concatMapAttrsStringSep "\n" (name: src: ''
      ln -s ${src} backend/boa_utils/src/module/builtin/vendor/${name}.js
      replace_args+=(--replace-fail ${lib.escapeShellArg src.url} ${lib.escapeShellArg "./builtin/vendor/${name}.js"})
    '') vendorSources.boa-utils}
    substituteInPlace backend/boa_utils/src/module/builtin.rs "''${replace_args[@]}"

    substituteInPlace backend/Cargo.toml \
      --replace-fail 'tray-icon = { git = "https://github.com/tauri-apps/tray-icon.git", rev = "34a3442" }' ""
  ''
  + lib.optionalString stdenv.hostPlatform.isLinux ''
    substituteInPlace $cargoDepsCopy/libappindicator-sys-*/src/lib.rs \
      --replace-fail "libayatana-appindicator3.so.1" "${libayatana-appindicator}/lib/libayatana-appindicator3.so.1"
  '';

  preBuild = ''
    # force sass-embedded to use our own sass from PATH instead of the bundled one
    substituteInPlace node_modules/.pnpm/sass-embedded@*/node_modules/sass-embedded/dist/lib/src/compiler-path.js \
      --replace-fail 'compilerCommand = (() => {' 'compilerCommand = (() => { return ["dart-sass"];'

    export HOME="$TMPDIR"

    pnpm run build:packages
    pnpm run web:build

    mkdir -p backend/tauri/tmp
    printf '%s\n' '${
      lib.toJSON {
        hash = finalAttrs.src.rev or "nixpkgs";
        author = "nixpkgs";
        time = "1970-01-01T00:00:01+00:00";
      }
    }' > backend/tauri/tmp/git-info.json
  '';

  postInstall = ''
    ICON_SIZES=("32x32" "128x128" "256x256@2")
    for size in "''${ICON_SIZES[@]}"; do
      mv $out/share/icons/hicolor/$size/apps/{"Clash Nyanpasu",clash_nyanpasu}.png
    done
    substituteInPlace $out/share/applications/"Clash Nyanpasu".desktop \
      --replace-fail "Icon=Clash Nyanpasu" "Icon=clash_nyanpasu"
  '';

  postFixup = ''
    ln -s ${lib.getExe mihomo} $out/bin/mihomo
    ln -s ${lib.getExe clash-rs} $out/bin/clash-rs
    ln -s ${lib.getExe nyanpasu-service} $out/bin/nyanpasu-service

    mkdir -p "$out/lib/Clash Nyanpasu/resources"
    ln -s ${meta-rules-dat.mmdb}/share/meta-rules-dat/mmdb/country.mmdb "$out/lib/Clash Nyanpasu/resources/Country.mmdb"
    ln -s ${meta-rules-dat.dat}/share/meta-rules-dat/dat/geosite.dat "$out/lib/Clash Nyanpasu/resources/geosite.dat"
    ln -s ${meta-rules-dat.dat}/share/meta-rules-dat/dat/geoip.dat "$out/lib/Clash Nyanpasu/resources/geoip.dat"
  '';

  checkFlags = [
    # require network
    "--skip=module::http::test_http_module_loader"
    "--skip=core::download::tests"
    "--skip=enhance::script::js::test::test_process_honey_with_fetch"
  ];

  # nix-update auto -u
  passthru.updateScript = ./update.sh;

  meta = {
    description = "Clash GUI based on Tauri";
    homepage = "https://github.com/libnyanpasu/clash-nyanpasu";
    license = lib.licenses.gpl3Plus;
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
    mainProgram = "Clash Nyanpasu";
    maintainers = with lib.maintainers; [ moraxyc ];
    broken = with stdenv.hostPlatform; isDarwin || (isAarch64 && isLinux);
  };
})
