# BakaMusic — a plugin-based, customizable, ad-free music player
# (Electron 43 app).
#
# Packaging principles (see the repository rules):
#   - Electron, libmpv (and its whole dependency tree: libplacebo, lua,
#     libass, ...) and libvips are reused from nixpkgs.
#   - LibreMPEG (./librempeg.nix) and koffi (./koffi.nix) are built from
#     source — the former because the app's AC-4 decoder only exists in
#     that FFmpeg fork, the latter because nixpkgs has no koffi package
#     and upstream only ships prebuilt binaries.
#   - sharp is rebuilt from source against nixpkgs libvips via sharp's
#     official global-libvips build path.
#   - get-windows is pure JavaScript on Linux (it shells out to xprop and
#     xwininfo), so no native rebuild is needed — only wrapper PATH entries.
#   - The qmc2/ence/taglib Node-API bindings are the one exception: their
#     sources live in the private repository Zencok/baka-native, so the
#     prebuilt binaries vendored in the upstream repo for exactly this
#     purpose (`npm run native:install`, offline, sha256-verified) are used
#     as-is and declared via meta.sourceProvenance. They are plain N-API
#     modules linked against libc and libstdc++; the wrapper's
#     LD_LIBRARY_PATH provides the latter.
{
  lib,
  stdenv,
  callPackage,
  source,
  fetchNpmDeps,
  npmHooks,
  makeWrapper,
  nodejs_24,
  electron,
  electron_43 ? electron,
  mpv-unwrapped,
  vips,
  pkg-config,
  binutils,
  python3,
  patchelf,
  zip,
  writeText,
  writeShellApplication,
  cacert,
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

  # Codec backend of the libmpv runtime. Everything mpv links besides this
  # comes from the nixpkgs mpv-unwrapped expression unmodified.
  librempeg = callPackage ./librempeg.nix {};
  libmpv = mpv-unwrapped.override {ffmpeg = librempeg;};

  koffi = callPackage ./koffi.nix {};

  # Arch naming used by Electron zips, the app's runtime directory layout
  # and the npm prebuilt package names. The fallbacks only keep evaluation
  # (which never builds) working on non-Linux platforms; meta.platforms
  # gates actual builds.
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

  npmDepsHash = "sha256-jfTXwUXh9/qdRs1Rd6Y8SmE1jK621buyX1hQ7elDyS8=";
  npmDeps =
    (fetchNpmDeps {
      inherit pname version src;
      hash = npmDepsHash;
      # BakaMusic's package.json uses npm `overrides` (node-gyp, uuid, tmp,
      # webpack-dev-server, ...). Version 2 caches registry packuments in
      # addition to tarballs, which is what npm needs whenever it has to
      # consult metadata (overrides resolution, optional peer deps).
      fetcherVersion = 2;
    }).overrideAttrs (prev: {
      nativeBuildInputs =
        (prev.nativeBuildInputs or [])
        ++ [
          nodejs_24
          cacert
        ];
      # Upstream's package-lock.json is missing `resolved`/`integrity` for
      # ~75% of its entries (npm/cli#6301); prefetch-npm-deps drops such
      # entries, which later makes `npm ci --offline` fail with ENOTCACHED.
      # Repair the lockfile in place (registry access is available in this
      # fixed-output derivation) before prefetch-npm-deps consumes it.
      postUnpack =
        (prev.postUnpack or "")
        + ''
          export NODE_EXTRA_CA_CERTS=${cacert}/etc/ssl/certs/ca-bundle.crt
          # postUnpack runs before genericBuild cd's into $sourceRoot, so
          # the lockfile lives under $sourceRoot, not the cwd.
          node ${./repair-lockfile.mjs} "$sourceRoot/package-lock.json"
        '';
    });

  # Same shape the upstream installer (scripts/install-media-runtimes.cjs)
  # writes for its `local-build` path; the app validates engine,
  # mediaBackend and decoders (must include "ac4") before accepting the
  # runtime.
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
      makeWrapper
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
    ];

    inherit npmDeps;

    # The default npm rebuild phase would run every dependency's install
    # scripts; get-windows unconditionally goes through node-pre-gyp (which
    # may try the network) even though it is pure JavaScript on Linux.
    # Native modules that actually need it are rebuilt explicitly in
    # preBuild below.
    npmRebuildFlags = ["--ignore-scripts"];

    dontNpmBuild = true;
    makeCacheWritable = true;

    env = {
      ELECTRON_SKIP_BINARY_DOWNLOAD = "1";
      SHARP_FORCE_GLOBAL_LIBVIPS = "1";
    };

    postPatch = ''
      # The fetchNpmDeps derivation repaired upstream's broken lockfile in
      # place and wrote it into its output; use that exact file here so the
      # lockfile consistency check passes and `npm ci` runs offline.
      cp ${npmDeps}/package-lock.json package-lock.json

      # Husky's prepare script fails outside a git checkout.
      npm pkg delete scripts.prepare

      # Match the upstream release flow, which stamps the tag version into
      # package.json before packaging. The lockfile is intentionally left
      # untouched: npmConfigHook diffs it against the vendored npm cache.
      npm pkg set "version=${version}"

      # Offline Electron runtime: point electron-packager at a directory of
      # Electron zips that preBuild synthesizes from the nixpkgs electron
      # dist (already patched for NixOS) instead of downloading a pristine
      # upstream zip.
      substituteInPlace forge.config.ts \
        --replace-fail '        executableName: "BakaMusic",' $'        electronZipDir: process.env.BAKAMUSIC_ELECTRON_ZIP_DIR,\n        executableName: "BakaMusic",'
    '';

    preBuild = ''
      # extract-zip 2 can terminate Electron Packager early on Node 24 and leave out/ empty.
      # Electron already provides its drop-in replacement, so this needs no lockfile change.
      substituteInPlace node_modules/@electron/packager/dist/unzip.js \
        --replace-fail 'require("extract-zip")' 'require("@electron-internal/extract-zip")'

      # --- 1. Offline Electron runtime for electron-packager ---
      #
      # electron-packager can only consume an Electron runtime from a flat
      # directory of electron-v<version>-<platform>-<arch>.zip files
      # (electronZipDir). Synthesize exactly one such zip from the nixpkgs
      # electron dist: it is already patched for NixOS, and the forge fuses
      # step later flips the fuse bytes (RunAsNode etc.) in the extracted
      # copy just like upstream does for the official binaries.
      electron_version=$(node -p "require('electron/package.json').version")
      if [[ $electron_version != "${electronPkg.version}" ]]; then
        echo "WARNING: npm electron $electron_version differs from nixpkgs electron ${electronPkg.version}; using the nixpkgs runtime" >&2
      fi
      export BAKAMUSIC_ELECTRON_ZIP_DIR="$PWD/.electron-zips"
      mkdir -p "$BAKAMUSIC_ELECTRON_ZIP_DIR"
      (
        cd ${electronPkg.dist}
        zip -X -q -r "$BAKAMUSIC_ELECTRON_ZIP_DIR/electron-v$electron_version-linux-${electronArch}.zip" .
      )

      # --- 2. sharp: rebuild from source against nixpkgs libvips ---
      #
      # sharp's build script probes pkg-config (vips-cpp >= 8.18.3) and
      # builds node_modules/sharp/src with node-gyp (headers via
      # npm_config_nodedir from npmConfigHook); cc-wrapper automatically
      # puts the vips store path in the rpath. The result replaces the
      # prebuilt binary of the matching @img/sharp-linux-* package — that
      # directory is the first resolution target of sharp.js and the forge
      # runtime-include plugin excludes node_modules/sharp/src — so the
      # packaging logic stays identical to upstream.
      npm run build --prefix node_modules/sharp
      cp node_modules/sharp/src/build/Release/sharp-linux-*.node \
        node_modules/@img/sharp-linux-${electronArch}/sharp.node

      # Remove prebuilt binaries of other platforms (and the wasm fallback):
      # a load failure must be loud instead of silently falling back to a
      # prebuilt variant.
      rm -rf node_modules/@img/sharp-libvips-*
      for dir in node_modules/@img/sharp-*; do
        [[ $dir == "node_modules/@img/sharp-linux-${electronArch}" ]] || rm -rf "$dir"
      done

      # --- 3. koffi: replace the prebuilt binaries with the source build ---
      koffi_dir=node_modules/@koromix/koffi-linux-${electronArch}
      cp ${koffi}/lib/koffi/${koffiTriplet}/koffi.node "$koffi_dir/${koffiTriplet}/koffi.node"
      rm -rf "$koffi_dir"/musl_*
      for dir in node_modules/@koromix/koffi-*; do
        [[ $dir == "$koffi_dir" ]] || rm -rf "$dir"
      done
      # The npm wrapper verifies the native module version at load time.
      # (koffi's package.json has an exports map without ./package.json, so
      # read the file instead of require().)
      node -e '
        const native = require("./" + process.argv[1]);
        const expected = JSON.parse(
          require("fs").readFileSync("node_modules/koffi/package.json", "utf8")
        ).version;
        if (native.version !== expected) {
          throw new Error(`koffi native ''${native.version} != ''${expected}`);
        }
      ' "$koffi_dir/${koffiTriplet}/koffi.node"

      # --- 4. Seed the libmpv runtime ---
      #
      # Same layout and runtime.json format the upstream installer produces
      # for its `local-build` path, but the content comes from nixpkgs mpv
      # rebuilt against our librempeg instead of a downloaded tarball.
      # libmpv's rpath holds absolute store paths, so no LD_LIBRARY_PATH is
      # needed at runtime. Like upstream, the ffmpeg/ffprobe programs are
      # not shipped; the AC-4 decoder is asserted by librempeg's own
      # installCheck.
      runtime_dir=res/.runtime/mpv/linux-${electronArch}
      mkdir -p "$runtime_dir/lib" "$runtime_dir/licenses/mpv" "$runtime_dir/licenses/librempeg"
      cp -a ${lib.getLib libmpv}/lib/libmpv.so.2* "$runtime_dir/lib/"
      cp ${mpv-unwrapped.src}/LICENSE.GPL ${mpv-unwrapped.src}/LICENSE.LGPL "$runtime_dir/licenses/mpv/"
      cp ${librempeg}/share/licenses/librempeg/* "$runtime_dir/licenses/librempeg/"
      cp ${runtimeJson} "$runtime_dir/runtime.json"

      # --- 5. Private prebuilt service modules (qmc2/ence/taglib) ---
      #
      # Sources live in the private repository Zencok/baka-native, so the
      # binaries upstream vendors for exactly this purpose are used as-is
      # (declared via meta.sourceProvenance). The installer verifies sha256
      # and works fully offline.
      npm run native:install

      # The prebuilt pool of the other architecture is installer input, not
      # runtime data; drop it from the packaged resources.
      case ${electronArch} in
        x64) rm -rf res/.service/native/prebuilt/linux-arm64 ;;
        arm64) rm -rf res/.service/native/prebuilt/linux-x64 ;;
      esac
    '';

    buildPhase = ''
      runHook preBuild

      # Only package (no makers): produces out/BakaMusic-linux-<arch>/.
      NODE_ENV=production npm exec -- electron-forge package

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      app_dir=$(echo out/BakaMusic-linux-*)
      [[ -d $app_dir ]]

      mkdir -p $out/lib/bakamusic
      cp -r "$app_dir/resources" $out/lib/bakamusic/resources
      # The fuse-flipped Electron binary, renamed by electron-packager.
      install -Dm755 "$app_dir/BakaMusic" $out/lib/bakamusic/BakaMusic

      # Everything else in the packaged tree is byte-identical to the zip
      # synthesized from the nixpkgs electron dist (packager only renames
      # the executable and replaces resources/). Link back to the store
      # copy instead of duplicating the Electron runtime.
      for entry in ${electronPkg.dist}/*; do
        base=$(basename "$entry")
        case $base in
          electron | resources) continue ;;
        esac
        ln -s "$entry" "$out/lib/bakamusic/$base"
      done

      install -Dm644 res/logo.png $out/share/icons/hicolor/512x512/apps/bakamusic.png
      install -Dm644 ${desktopFile} $out/share/applications/bakamusic.desktop

      makeWrapper $out/lib/bakamusic/BakaMusic $out/bin/bakamusic \
        --add-flags "\''${NIXOS_OZONE_WL:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime}" \
        --prefix PATH : ${lib.makeBinPath [xdg-utils xprop xwininfo]} \
        --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [stdenv.cc.cc.lib]}

      runHook postInstall
    '';

    doInstallCheck = true;
    installCheckPhase = ''
      runHook preInstallCheck

      resources=$out/lib/bakamusic/resources

      test -x $out/lib/bakamusic/BakaMusic
      test -f $resources/app.asar
      grep -q "Exec=bakamusic" $out/share/applications/bakamusic.desktop
      test -f $out/share/icons/hicolor/512x512/apps/bakamusic.png

      # The libmpv runtime is seeded and linked against the librempeg build
      # (the AC-4 decoder itself is asserted by librempeg's installCheck).
      runtime_dir=$resources/res/.runtime/mpv/linux-${electronArch}
      test -e "$runtime_dir/lib/libmpv.so.2"
      grep -q '"ac4"' "$runtime_dir/runtime.json"
      patchelf --print-rpath "$runtime_dir/lib/libmpv.so.2" | grep -qF "${librempeg}"

      # The private prebuilt service modules are in place and all their
      # NEEDED libraries resolve with the wrapper's LD_LIBRARY_PATH.
      for module in qmc2 ence taglib; do
        module_path=$resources/res/.service/native/$module.node
        test -f "$module_path"
        if LD_LIBRARY_PATH=${lib.makeLibraryPath [stdenv.cc.cc.lib]} ldd "$module_path" | grep "not found"; then
          echo "unresolved dependencies in $module.node" >&2
          exit 1
        fi
      done

      # The packaged koffi native module is the one built from source.
      koffi_node=$(find $resources/app.asar.unpacked -path "*@koromix/koffi-linux-*/linux_*/koffi.node" | head -n 1)
      test -n "$koffi_node"
      cmp "$koffi_node" ${koffi}/lib/koffi/${koffiTriplet}/koffi.node

      # sharp was rebuilt from source against nixpkgs libvips.
      sharp_node=$(find $resources/app.asar.unpacked -path "*@img/sharp-linux-*/sharp.node" | head -n 1)
      test -n "$sharp_node"
      patchelf --print-rpath "$sharp_node" | grep -qF "${vips}"

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
      # The vendored qmc2/ence/taglib prebuilt Node-API modules (private
      # sources) and the prebuilt binaries that ship inside the upstream
      # tarball for other platforms.
      sourceProvenance = [lib.sourceTypes.binaryNativeCode];
    };
  }
