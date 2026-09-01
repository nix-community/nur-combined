{
  lib,
  stdenv,
  source,
  fetchPnpmDeps,
  pnpmConfigHook,
  pnpm_10,
  nodejs,
  electron,
  python3,
  makeWrapper,
  xdg-utils,
}: let
  inherit (source) pname src;
  version = lib.removePrefix "v" source.version;

  # Cross-platform pnpm store hash refreshed by update-hashes.
  pnpmDepsHash = "sha256-3glelHHfcBvJfI+mqvSug684TZ3EnvN/x62Gugp+AN8=";
in
  stdenv.mkDerivation {
    inherit pname src version;

    # Package only app.asar for nixpkgs Electron; rebuild the native better-sqlite3 module against its headers.
    pnpmDeps = fetchPnpmDeps {
      inherit pname version src;
      pnpm = pnpm_10;
      fetcherVersion = 4;
      hash = pnpmDepsHash;
    };

    nativeBuildInputs = [
      makeWrapper
      nodejs
      pnpm_10
      pnpmConfigHook
      python3 # node-gyp
    ];

    env = {
      # Prevent downloading Electron from npm.
      ELECTRON_SKIP_BINARY_DOWNLOAD = "1";

      # Build better-sqlite3 offline against Electron's headers.
      npm_config_runtime = "electron";
      npm_config_target = electron.version;
      npm_config_nodedir = "${electron.headers}";
    };

    preBuild = ''
      # pnpm skips install scripts, so drive the hoisted node-gyp the way upstream's own deps:* scripts do.
      pushd node_modules/better-sqlite3
      node ../node-gyp/bin/node-gyp.js rebuild --release
      popd
    '';

    buildPhase = ''
      runHook preBuild

      cd icalingua
      # Build app.asar offline with rspack and electron-builder.
      pnpm run build:ci
      pnpm exec electron-builder --dir \
        -c.electronDist=${electron.dist} \
        -c.electronVersion=${electron.version}

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      # Copy the architecture-specific unpacked output.
      mkdir -p $out/lib/icalingua
      cp -r build/linux*-unpacked/resources/app.asar* $out/lib/icalingua/

      install -Dm644 ../pkgres/512x512.png \
        $out/share/icons/hicolor/512x512/apps/icalingua.png
      install -Dm644 ../pkgres/icalingua.desktop \
        $out/share/applications/icalingua.desktop

      # Enable Wayland flags at runtime when `NIXOS_OZONE_WL` is set.
      makeWrapper ${lib.getExe electron} $out/bin/icalingua \
        --add-flags "$out/lib/icalingua/app.asar" \
        --add-flags "\''${NIXOS_OZONE_WL:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime}" \
        --prefix PATH : ${lib.makeBinPath [xdg-utils]}

      runHook postInstall
    '';

    doInstallCheck = true;
    installCheckPhase = ''
      runHook preInstallCheck

      test -x $out/bin/icalingua
      test -f $out/lib/icalingua/app.asar
      test -f $out/share/applications/icalingua.desktop
      test -f $out/share/icons/hicolor/512x512/apps/icalingua.png

      # Verify the unpacked better-sqlite3 module under headless Electron.
      node_module="$(find $out/lib/icalingua/app.asar.unpacked -name 'better_sqlite3.node' | head -n1)"
      test -n "$node_module"
      ELECTRON_RUN_AS_NODE=1 ${lib.getExe electron} -e "require('$node_module')"

      # Verify wrapper arguments.
      grep -F "$out/lib/icalingua/app.asar" $out/bin/icalingua
      grep -F 'NIXOS_OZONE_WL' $out/bin/icalingua

      runHook postInstallCheck
    '';

    meta = {
      description = "A client for QQ and more";
      homepage = "https://github.com/Icalingua-plus-plus/Icalingua-plus-plus";
      changelog = "https://github.com/Icalingua-plus-plus/Icalingua-plus-plus/releases/tag/v${version}";
      license = lib.licenses.agpl3Only;
      mainProgram = "icalingua";
      maintainers = [
        {
          name = "mzwing";
        }
      ];
      platforms = [
        "x86_64-linux"
        "aarch64-linux"
      ];
    };
  }
