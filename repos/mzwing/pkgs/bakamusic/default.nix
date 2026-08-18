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
#   - The qmc2/ence/taglib/transcode Node-API bindings are the one
#     exception: scripts/build-native.js builds them from a native/ checkout
#     that only exists in Zencok/baka-native, which is private (the repo and
#     its release assets both 404), so the prebuilt binaries vendored in the
#     upstream repo for exactly this purpose (`npm run native:install`,
#     offline, sha256-verified) are used as-is and declared via
#     meta.sourceProvenance. They are plain N-API modules needing only libc
#     and libstdc++; the wrapper's LD_LIBRARY_PATH provides the latter.
#     taglib.node statically links upstream TagLib (2.3.1 at this pin) and
#     transcode.node dlopens the seeded libmpv, but both bindings themselves
#     are baka-native's.
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

  npmDepsHash = "sha256-mBfCRrJebTctb9cU7zKHp/VDb7gIoFaF4cwiKW0098k=";
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
      # What wrapper.nix carries for GSETTINGS_SCHEMAS_PATH; librsvg, gtk3
      # and dconf come along with wrapGAppsHook3 itself.
      gsettings-desktop-schemas
      glib
      gtk3
      gtk4
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

      # Zip a writable copy rather than the store dist directly. zip records the
      # store's read-only modes and extract-zip restores them, so packager then
      # fails with EACCES trying to unlink resources/default_app.asar — removing
      # a directory entry needs write permission on the directory, not the file.
      # Only the modes differ; installPhase still links the runtime back to the
      # store dist, so the packaged output is unchanged.
      electron_dist=$(mktemp -d)
      cp -r ${electronPkg.dist}/. "$electron_dist"
      chmod -R u+w "$electron_dist"
      (
        cd "$electron_dist"
        # -0 stores without compressing: packager extracts this zip on the same
        # machine moments later, so deflating the whole runtime is pure waste.
        zip -X -0 -q -r "$BAKAMUSIC_ELECTRON_ZIP_DIR/electron-v$electron_version-linux-${electronArch}.zip" .
      )
      rm -rf "$electron_dist"

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

      runHook postInstall
    '';

    # wrapper.nix applies gappsWrapperArgs by hand for the same reason.
    dontWrapGApps = true;

    # What launches is electron-packager's own copy of the binary, so nixpkgs'
    # electron wrapper never runs and everything wrapper.nix would have set has
    # to be set here: the GTK/GSettings environment, plus CHROME_DEVEL_SANDBOX.
    # Chromium reads the chrome-sandbox next to the executable as a user-managed
    # build (no store file is setuid root) and kills the zygote with SIGILL
    # unless that variable names the helper explicitly; naming it is all it
    # wants, the sandboxing itself still comes from user namespaces.
    preFixup = ''
      # makeShellWrapper because wrapGAppsHook3 propagates makeBinaryWrapper,
      # which shadows makeWrapper and bakes flags in literally instead of
      # expanding NIXOS_OZONE_WL at run time; preFixup because gappsWrapperArgs
      # is filled by a preFixupPhases hook, i.e. only after installPhase.
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

      # Every assertion below reports itself. They are all `test`/`grep -q`/`cmp`,
      # which say nothing when they fail, so under `set -e` the phase used to die
      # with no output at all — and since the package never built this far before,
      # none of them had ever actually run.
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

      # Both halves matter: a dangling symlink here or a wrapper that forgets
      # the variable is the same SIGILL at zygote startup.
      assert 'the chrome-sandbox helper is missing' test -x $out/lib/bakamusic/chrome-sandbox
      assert 'the wrapper does not set CHROME_DEVEL_SANDBOX' \
        grep -q "CHROME_DEVEL_SANDBOX=.*$out/lib/bakamusic/chrome-sandbox" $out/bin/bakamusic

      # A gappsWrapperArgs that expanded to nothing — the wrapper built too
      # early, say — is silent until GTK aborts on a missing schema.
      assert 'the wrapper carries no GSettings schemas' \
        grep -q 'gsettings-schemas' $out/bin/bakamusic

      assert 'the desktop entry does not exec bakamusic' \
        grep -q "Exec=bakamusic" $out/share/applications/bakamusic.desktop
      assert 'the icon is missing' test -f $out/share/icons/hicolor/512x512/apps/bakamusic.png

      # The libmpv runtime is seeded and linked against the librempeg build
      # (the AC-4 decoder itself is asserted by librempeg's installCheck).
      runtime_dir=$resources/res/.runtime/mpv/linux-${electronArch}
      assert 'libmpv is missing from the seeded runtime' test -e "$runtime_dir/lib/libmpv.so.2"
      assert 'the seeded runtime does not advertise ac4' grep -q '"ac4"' "$runtime_dir/runtime.json"
      assert "libmpv is not linked against ${librempeg}" \
        grep -qF "${librempeg}" <(patchelf --print-rpath "$runtime_dir/lib/libmpv.so.2")

      # The private prebuilt service modules are in place and every NEEDED library
      # resolves with the wrapper's LD_LIBRARY_PATH. ldd needs the file to be
      # executable and store files are not, so check a writable copy — otherwise
      # ldd only warns, prints no dependencies, and the grep below always passes.
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

      # The packaged koffi native module is the one built from source. fixupPhase
      # shrinks RPATHs in the packaged tree, so compare what the loader needs
      # rather than the bytes, which no longer match by construction.
      koffi_node=$(find $resources/app.asar.unpacked -path "*@koromix/koffi-linux-*/linux_*/koffi.node" | head -n 1)
      assert 'the packaged koffi native module is missing' test -n "$koffi_node"
      assert 'the packaged koffi module is not the one built from source' \
        cmp -s <(patchelf --print-needed "$koffi_node") \
        <(patchelf --print-needed ${koffi}/lib/koffi/${koffiTriplet}/koffi.node)

      # sharp was rebuilt from source against nixpkgs libvips.
      sharp_node=$(find $resources/app.asar.unpacked -path "*@img/sharp-linux-*/sharp.node" | head -n 1)
      assert 'the packaged sharp native module is missing' test -n "$sharp_node"
      # getLib, not the bare package: vips lists "bin" first, so ${vips} is the
      # executables-only output and libvips-cpp.so lives in "out".
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
      # The vendored qmc2/ence/taglib prebuilt Node-API modules (private
      # sources) and the prebuilt binaries that ship inside the upstream
      # tarball for other platforms.
      sourceProvenance = [lib.sourceTypes.binaryNativeCode];
    };
  }
