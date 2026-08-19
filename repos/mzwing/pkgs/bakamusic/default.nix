# Electron app using nixpkgs runtimes, source-built LibreMPEG, koffi and sharp, plus declared private service modules.
{
  lib,
  stdenv,
  callPackage,
  source,
  fetchNpmDeps,
  npmHooks,
  makeShellWrapper,
  wrapGAppsHook3,
  nodejs_24,
  electron,
  electron_43 ? electron,
  mpv-unwrapped,
  vips,
  gsettings-desktop-schemas,
  glib,
  gtk3,
  gtk4,
  pkg-config,
  binutils,
  python3,
  patchelf,
  zip,
  writeText,
  writeShellApplication,
  coreutils,
  curl,
  jq,
  nix,
  xdg-utils,
  xprop,
  xwininfo,
}: let
  inherit (source) pname src;
  version = lib.removePrefix "v" source.version;

  pins = lib.importJSON ./pins.json;

  electronPkg = electron_43;

  # Replace only mpv's codec backend with LibreMPEG.
  librempeg = callPackage ./librempeg.nix {};
  libmpv = mpv-unwrapped.override {ffmpeg = librempeg;};

  koffi = callPackage ./koffi.nix {};

  # Runtime architecture names with non-building evaluation fallbacks.
  electronArch =
    {
      x86_64-linux = "x64";
      aarch64-linux = "arm64";
    }.${
      stdenv.hostPlatform.system
    } or "x64";
  koffiTriplet =
    {
      x86_64-linux = "linux_x64";
      aarch64-linux = "linux_arm64";
    }.${
      stdenv.hostPlatform.system
    } or "linux_x64";

  npmDepsHash = "sha256-+W0K9ETI4yZxzDkMZmYn1Ks2ha6qvFpkYnTQpimFadY=";
  npmDeps = fetchNpmDeps {
    inherit pname version src;
    hash = npmDepsHash;
    # Cache registry metadata needed by npm overrides.
    fetcherVersion = 2;
  };

  # Runtime metadata expected by the upstream local-build installer.
  runtimeJson = writeText "runtime.json" (builtins.toJSON {
    schemaVersion = 1;
    name = "mpv-libre-runtime";
    inherit (pins.mpvRuntime) version engine mediaBackend decoders;
    license = "AGPL-3.0-or-later";
    platform = "linux-${electronArch}";
    source = "local-build";
    sourceCommits.librempeg = pins.mpvRuntime.librempeg.commit;
    nixpkgs.mpv = libmpv.version;
  });

  desktopFile = writeText "bakamusic.desktop" ''
    [Desktop Entry]
    Type=Application
    Name=BakaMusic
    Comment=Plugin-based, customizable, ad-free music player
    Exec=bakamusic %u
    Icon=bakamusic
    Terminal=false
    Categories=AudioVideo;Audio;Player;
    MimeType=x-scheme-handler/bakamusic;
    StartupWMClass=BakaMusic
  '';
in
  stdenv.mkDerivation {
    inherit pname src version;

    nativeBuildInputs = [
      makeShellWrapper
      wrapGAppsHook3
      nodejs_24
      npmHooks.npmConfigHook
      python3 # node-gyp (sharp)
      pkg-config # sharp's global-libvips probe
      binutils # readelf, used by sharp's ABI check
      patchelf # installCheck rpath assertions
      zip # synthesizing the Electron runtime zip
    ];

    buildInputs = [
      vips # sharp --build-from-source against the system libvips
      # Additional GSettings schemas for the wrapper.
      gsettings-desktop-schemas
      glib
      gtk3
      gtk4
    ];

    inherit npmDeps;

    # Skip dependency scripts and rebuild required native modules explicitly.
    npmRebuildFlags = ["--ignore-scripts"];

    dontNpmBuild = true;
    makeCacheWritable = true;

    env = {
      ELECTRON_SKIP_BINARY_DOWNLOAD = "1";
      SHARP_FORCE_GLOBAL_LIBVIPS = "1";
    };

    postPatch = ''
      # Reuse the repaired lockfile from the npm dependency output.
      cp ${npmDeps}/package-lock.json package-lock.json

      # Disable Husky outside a git checkout.
      npm pkg delete scripts.prepare

      # Stamp the release version without changing the lockfile.
      npm pkg set "version=${version}"

      # Use a synthesized nixpkgs Electron zip offline.
      substituteInPlace forge.config.ts \
        --replace-fail '        executableName: "BakaMusic",' $'        electronZipDir: process.env.BAKAMUSIC_ELECTRON_ZIP_DIR,\n        executableName: "BakaMusic",'
    '';

    preBuild = ''
      # Replace extract-zip 2 with Electron's Node 24-compatible implementation.
      substituteInPlace node_modules/@electron/packager/dist/unzip.js \
        --replace-fail 'require("extract-zip")' 'require("@electron-internal/extract-zip")'

      # Synthesize electron-packager's expected runtime zip from nixpkgs Electron.
      electron_version=$(node -p "require('electron/package.json').version")
      if [[ $electron_version != "${electronPkg.version}" ]]; then
        echo "WARNING: npm electron $electron_version differs from nixpkgs electron ${electronPkg.version}; using the nixpkgs runtime" >&2
      fi
      export BAKAMUSIC_ELECTRON_ZIP_DIR="$PWD/.electron-zips"
      mkdir -p "$BAKAMUSIC_ELECTRON_ZIP_DIR"

      # Zip a writable copy so packager can replace default_app.asar.
      electron_dist=$(mktemp -d)
      cp -r ${electronPkg.dist}/. "$electron_dist"
      chmod -R u+w "$electron_dist"
      (
        cd "$electron_dist"
        # Skip compression for this short-lived local zip.
        zip -X -0 -q -r "$BAKAMUSIC_ELECTRON_ZIP_DIR/electron-v$electron_version-linux-${electronArch}.zip" .
      )
      rm -rf "$electron_dist"

      # Rebuild sharp against nixpkgs libvips and replace its platform binary.
      npm run build --prefix node_modules/sharp
      cp node_modules/sharp/src/build/Release/sharp-linux-*.node \
        node_modules/@img/sharp-linux-${electronArch}/sharp.node

      # Remove foreign and fallback sharp binaries.
      rm -rf node_modules/@img/sharp-libvips-*
      for dir in node_modules/@img/sharp-*; do
        [[ $dir == "node_modules/@img/sharp-linux-${electronArch}" ]] || rm -rf "$dir"
      done

      # Replace prebuilt koffi with the source build.
      koffi_dir=node_modules/@koromix/koffi-linux-${electronArch}
      cp ${koffi}/lib/koffi/${koffiTriplet}/koffi.node "$koffi_dir/${koffiTriplet}/koffi.node"
      rm -rf "$koffi_dir"/musl_*
      for dir in node_modules/@koromix/koffi-*; do
        [[ $dir == "$koffi_dir" ]] || rm -rf "$dir"
      done
      # Verify the source-built koffi version without package exports.
      node -e '
        const native = require("./" + process.argv[1]);
        const expected = JSON.parse(
          require("fs").readFileSync("node_modules/koffi/package.json", "utf8")
        ).version;
        if (native.version !== expected) {
          throw new Error(`koffi native ''${native.version} != ''${expected}`);
        }
      ' "$koffi_dir/${koffiTriplet}/koffi.node"

      # Seed the upstream runtime layout with nixpkgs mpv and LibreMPEG.
      runtime_dir=res/.runtime/mpv/linux-${electronArch}
      mkdir -p "$runtime_dir/lib" "$runtime_dir/licenses/mpv" "$runtime_dir/licenses/librempeg"
      cp -a ${lib.getLib libmpv}/lib/libmpv.so.2* "$runtime_dir/lib/"
      cp ${mpv-unwrapped.src}/LICENSE.GPL ${mpv-unwrapped.src}/LICENSE.LGPL "$runtime_dir/licenses/mpv/"
      cp ${librempeg}/share/licenses/librempeg/* "$runtime_dir/licenses/librempeg/"
      cp ${runtimeJson} "$runtime_dir/runtime.json"

      # Install checksum-verified service modules whose sources are private.
      npm run native:install

      # Remove installer inputs for the other architecture.
      case ${electronArch} in
        x64) rm -rf res/.service/native/prebuilt/linux-arm64 ;;
        arm64) rm -rf res/.service/native/prebuilt/linux-x64 ;;
      esac
    '';

    buildPhase = ''
      runHook preBuild

      # Package without platform makers.
      NODE_ENV=production npm exec -- electron-forge package

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      app_dir=$(echo out/BakaMusic-linux-*)
      [[ -d $app_dir ]]

      mkdir -p $out/lib/bakamusic
      cp -r "$app_dir/resources" $out/lib/bakamusic/resources
      # Install the fuse-configured Electron binary.
      install -Dm755 "$app_dir/BakaMusic" $out/lib/bakamusic/BakaMusic

      # Link unchanged Electron runtime files back to nixpkgs.
      for entry in ${electronPkg.dist}/*; do
        base=$(basename "$entry")
        case $base in
          electron | resources) continue ;;
        esac
        ln -s "$entry" "$out/lib/bakamusic/$base"
      done

      install -Dm644 res/logo.png $out/share/icons/hicolor/512x512/apps/bakamusic.png
      install -Dm644 ${desktopFile} $out/share/applications/bakamusic.desktop

      runHook postInstall
    '';

    # Apply GApp arguments manually below.
    dontWrapGApps = true;

    # Recreate nixpkgs Electron wrapper settings for GTK, GSettings and the Chromium sandbox helper.
    preFixup = ''
      # Use a shell wrapper after wrapGAppsHook3 populates runtime arguments.
      makeShellWrapper $out/lib/bakamusic/BakaMusic $out/bin/bakamusic \
        "''${gappsWrapperArgs[@]}" \
        --add-flags "\''${NIXOS_OZONE_WL:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime}" \
        --set CHROME_DEVEL_SANDBOX $out/lib/bakamusic/chrome-sandbox \
        --prefix PATH : ${lib.makeBinPath [xdg-utils xprop xwininfo]} \
        --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [stdenv.cc.cc.lib]}
    '';

    doInstallCheck = true;
    installCheckPhase = ''
      runHook preInstallCheck

      # Report each silent assertion failure.
      assert() {
        local description=$1
        shift
        if ! "$@"; then
          echo "installCheck: $description" >&2
          exit 1
        fi
      }

      resources=$out/lib/bakamusic/resources

      assert 'the launcher binary is missing' test -x $out/lib/bakamusic/BakaMusic
      assert 'app.asar is missing' test -f $resources/app.asar

      # Verify the sandbox helper and wrapper variable together.
      assert 'the chrome-sandbox helper is missing' test -x $out/lib/bakamusic/chrome-sandbox
      assert 'the wrapper does not set CHROME_DEVEL_SANDBOX' \
        grep -q "CHROME_DEVEL_SANDBOX=.*$out/lib/bakamusic/chrome-sandbox" $out/bin/bakamusic

      # Verify GSettings schemas reached the wrapper.
      assert 'the wrapper carries no GSettings schemas' \
        grep -q 'gsettings-schemas' $out/bin/bakamusic

      assert 'the desktop entry does not exec bakamusic' \
        grep -q "Exec=bakamusic" $out/share/applications/bakamusic.desktop
      assert 'the icon is missing' test -f $out/share/icons/hicolor/512x512/apps/bakamusic.png

      # Verify the seeded LibreMPEG-backed runtime.
      runtime_dir=$resources/res/.runtime/mpv/linux-${electronArch}
      assert 'libmpv is missing from the seeded runtime' test -e "$runtime_dir/lib/libmpv.so.2"
      assert 'the seeded runtime does not advertise ac4' grep -q '"ac4"' "$runtime_dir/runtime.json"
      assert "libmpv is not linked against ${librempeg}" \
        grep -qF "${librempeg}" <(patchelf --print-rpath "$runtime_dir/lib/libmpv.so.2")

      # Check service module dependencies on executable writable copies.
      probe_dir=$(mktemp -d)
      for module in qmc2 ence taglib transcode; do
        module_path=$resources/res/.service/native/$module.node
        assert "$module.node is missing" test -f "$module_path"

        install -m755 "$module_path" "$probe_dir/$module.node"
        if ! LD_LIBRARY_PATH=${lib.makeLibraryPath [stdenv.cc.cc.lib]} \
          ldd "$probe_dir/$module.node" >"$probe_dir/$module.ldd"; then
          echo "installCheck: ldd could not inspect $module.node" >&2
          cat "$probe_dir/$module.ldd" >&2
          exit 1
        fi
        if grep 'not found' "$probe_dir/$module.ldd"; then
          echo "installCheck: unresolved dependencies in $module.node" >&2
          exit 1
        fi
      done

      # Compare koffi dependencies because fixup changes its bytes.
      koffi_node=$(find $resources/app.asar.unpacked -path "*@koromix/koffi-linux-*/linux_*/koffi.node" | head -n 1)
      assert 'the packaged koffi native module is missing' test -n "$koffi_node"
      assert 'the packaged koffi module is not the one built from source' \
        cmp -s <(patchelf --print-needed "$koffi_node") \
        <(patchelf --print-needed ${koffi}/lib/koffi/${koffiTriplet}/koffi.node)

      # Verify the source-built sharp module.
      sharp_node=$(find $resources/app.asar.unpacked -path "*@img/sharp-linux-*/sharp.node" | head -n 1)
      assert 'the packaged sharp native module is missing' test -n "$sharp_node"
      # libvips lives in the library output, not the default bin output.
      assert "sharp is not linked against ${lib.getLib vips}" \
        grep -qF "${lib.getLib vips}" <(patchelf --print-rpath "$sharp_node")

      runHook postInstallCheck
    '';

    passthru.pinUpdater = writeShellApplication {
      name = "bakamusic-pin-updater";
      runtimeInputs = [
        coreutils
        curl
        jq
        nix
      ];
      runtimeEnv.PIN_UTILS = ../../scripts/package-updates/lib/pin-utils.sh;
      excludeShellChecks = [
        "SC1090" # PIN_UTILS is injected via runtimeEnv.
        "SC1091"
        "SC2154"
      ];
      text = builtins.readFile ./update-pins.sh;
    };

    meta = {
      description = "Plugin-based, customizable, ad-free music player";
      homepage = "https://github.com/Zencok/BakaMusic";
      changelog = "https://github.com/Zencok/BakaMusic/releases/tag/v${version}";
      license = lib.licenses.agpl3Only;
      mainProgram = "bakamusic";
      maintainers = [
        {
          name = "mzwing";
        }
      ];
      platforms = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      # Upstream vendored native modules with private or platform-specific sources.
      sourceProvenance = [lib.sourceTypes.binaryNativeCode];
    };
  }
